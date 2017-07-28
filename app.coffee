express = require('express')
MysqlDB = require('./helpers/mysql')
User = require('./user')

config = require('./config')

db = new MysqlDB(require('mysql').createConnection(config.db))


app = express()
app.listen(config.port)
if config.development
  require('./app_dev').init(app)

app_check = (req, res, next)->
  if !req.query.callback
    return res.send '{}'
  if !(req.query.app_id and config.apps[parseInt(req.query.app_id)])
    return res.send '{error: "app_id"}'
  next()

jsonp = (req, res, data)-> res.send(req.query.callback + '('+ JSON.stringify(data) + ');')


app.get '/user.json', app_check, (req, res)->
  app_id = parseInt(req.query.app_id)
  app = config.apps[app_id]
  app['id'] = app_id
  user = new User({
    dr_auth_code: req.query.dr_auth_code
    session: req.query.session
    db: db
    app: app
  })
  user.check (data)->
    if !data
      return jsonp(req, res, {error: 'check'})
    user.save data, req.query, =>
      jsonp req, res, data


console.info "http://localhost:#{config.port}/"
