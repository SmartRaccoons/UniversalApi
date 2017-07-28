_ = require('lodash')

api_draugiem = require('./api/draugiem').Draugiem


module.exports = class User
  constructor: (options)->
    @options = options

  _select: (params, callback)->
    @options.db.select {
      table: 'auth_user'
      fields: ['id', 'name', 'data', 'session']
      one: true
      where: _.extend {
        app_id: @options.app.id
      }, params
    }, (user)=>
      if user
        user.data = JSON.parse(user.data)
      callback(user)

  _update: (params, callback)->
    @options.db.update _.extend({
      table: 'auth_user'
    }, params), callback

  _insert: (params, callback)->
    @options.db.insert {
      table: 'auth_user'
      data: _.extend({app_id: @options.app.id}, params)
    }, callback

  check: (callback)->
    if @options.session
      return @_check_session(callback)
    if @options.dr_auth_code
      api = new api_draugiem(@options.app.dr_app_hash)
      return api.authorize @options.dr_auth_code, ((user)=>
        if !user
          return callback()
        @_save {
          name: [user.name, user.surname].join(' ')
          dr_uid: user.uid
          data: {
            img: user.img
            birthday: user.birthday
          }
        }, callback
      ), callback

    return @_save({name: '', data: {}}, callback)

  _get_query_data: (query)->
    d = {}
    for k, v of query
      if k.substr(0, 5) is 'data.'
        d[k.substr(5)] = v
    if Object.keys(d).length is 0 then false else d

  save: (user, query, callback)->
    data = @_get_query_data(query)
    if !data
      return callback(user)
    user.data = _.extend(user.data, data)
    @_update {where: {id: user.id}, data: _.pick(user, ['data'])}, => callback(user)


  _check_session: (callback)->
    @_select {
      session: @options.session
    }, (data)=>
      if data
        return callback(data)
      delete @options.session
      return @check(callback)

  _session: (length=36, chars='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')->
    [0...length].map( ()-> chars[Math.floor(Math.random() * chars.length)]).join('')

  _create: (user, callback)->
    @_insert user, (user_id)=>
      user.id = user_id
      callback(user)

  _save: (user, callback)->
    user.session = @_session()
    where = _.pick user, ['dr_uid']
    if Object.keys(where).length is 0
      return @_create user, callback
    @_select where, (data)=>
      if !data
        return @_create user, callback
      user.id = data.id
      @_update({where: {id: user.id}, data: _.pick(user, ['session', 'name'])})
      callback(user)
