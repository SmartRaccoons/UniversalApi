
exports.development = false
exports.port = 1234
exports.db = 'mysql://root@127.0.0.1/universalapi'

exports.apps = {
  1: {
    dr_app_id: '1511'
    dr_app_hash: 'fd2'
  }
}

_ = require('lodash')
_.extend(exports, require('./config.local'))
