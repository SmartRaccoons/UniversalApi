_ = require('lodash')


module.exports = class DB
  constructor: (db)->
    @db = db

  _fields: (f)->
    f.map( (v)-> "`#{v}`").join(', ')

  _where: (wh)->
    if !wh
      return ''
    params = []
    for f, v of wh
      params.push "`#{f}`=#{@db.escape(v)}"
    """
    WHERE
      #{params.join(' AND ')}
    """

  _json_check: (data)->
    d = {}
    for k, v of data
      d[k] = if _.isObject(v) then JSON.stringify(v) else v
    d

  insert: (params, callback=->)->
    @db.query """INSERT INTO `#{params.table}` SET ?""", @_json_check(params.data), (err, result)->
      if err
        console.info params
        throw err
      callback(result.insertId)

  update: (params, callback=->)->
    @db.query "UPDATE `#{params.table}` SET ? #{@_where(params.where)}", @_json_check(params.data), (err, result)->
      if err
        console.info params
        throw err
      callback(result)

  select: (params, callback)->
    @db.query """
      SELECT
        #{@_fields(params.fields)}
      FROM
        `#{params.table}`
      #{@_where(params.where)}

      #{if params.one then 'LIMIT 1' else ''}
    """, (err, rows)=>
      if err
        throw err
      if params.one
        return callback(rows[0])
      if !(params.filter and params.filter.by)
        return callback(rows)
      result = {}
      rows.forEach (r)->
        if !params.filter.by_multiply
          return result[r[params.filter.by]] = r
        if !result[r[params.filter.by]]
          result[r[params.filter.by]] = []
        result[r[params.filter.by]].push r
      callback(result)
