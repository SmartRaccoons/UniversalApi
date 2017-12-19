_ = require('lodash')

api_draugiem = require('./api/draugiem').Draugiem

_session_str = (length=36, chars='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')->
  [0...length].map( ()-> chars[Math.floor(Math.random() * chars.length)]).join('')

_get_query_data = (query)->
  d = {}
  for k, v of query
    if k.substr(0, 5) is 'data.'
      d[k.substr(5)] = v
  if Object.keys(d).length is 0 then false else d


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
    if @options.dr_auth_code and @options.app.dr_app_hash
      return @_check_draugiem(callback)
    if @options.session
      return @_check_session(callback)
    return @_create_session({name: '', data: {}}, callback)

  _check_draugiem: (callback)->
    table = 'session_dr'
    @options.db.select {
      table: table
      fields: ['user_id', 'api_key']
      one: true
      where: {
        app_id: @options.app.id
        code: @options.dr_auth_code
        updated: {
          operator: '>'
          value: new Date(new Date().getTime()-1000 * 60 * 60 * 24 * 30)
        }
      }
    }, (data)=>
      if data
        return @_create_session {id: data.user_id}, callback
      api = new api_draugiem(@options.app.dr_app_hash)
      api.authorize @options.dr_auth_code, ((user)=>
        if !user
          return callback()
        @_create_session {
          name: [user.name, user.surname].join(' ')
          dr_uid: user.uid
          data: {
            img: user.img
            birthday: user.birthday
          }
        }, (user)=>
          callback(user)
          @options.db.insert {
            table: table
            data: {user_id: user.id, api_key: api.app_key, app_id: @options.app.id, code: @options.dr_auth_code, updated: new Date()}
          }
      ), callback

  _check_session: (callback)->
    @_select {
      session: @options.session
    }, (data)=>
      if data
        return callback(data)
      return @_create_session({name: '', data: {}}, callback)

  save: (user, query, callback)->
    data = _get_query_data(query)
    if !data
      return callback(user)
    user.data = _.extend(user.data, data)
    @_update {where: {id: user.id}, data: _.pick(user, ['data'])}, => callback(user)

  _create: (user, callback)->
    @_insert user, (user_id)=>
      user.id = user_id
      callback(user)

  _create_session: (user, callback)->
    user.session = _session_str()
    where = _.pick user, ['dr_uid', 'id']
    if Object.keys(where).length is 0
      return @_create user, callback
    @_select where, (data)=>
      if !data
        return @_create user, callback
      user.data = if user.data then _.extend(data.data, user.data) else data.data
      user = _.extend(user, _.pick(data, ['id', 'name']))
      @_update({where: {id: user.id}, data: _.pick(user, ['session', 'name'])})
      callback(user)
