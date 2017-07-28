nock = require('nock')

exports.init = ->

    nock('http://api.draugiem.lv')
      .get('/json/?&code=1&app=fd2&action=authorize')
      .reply(200, '{"apikey":"api1","uid":"1","language":"lv","users":{"1":{"uid":1,"name":"Vards 1","surname":"Uzvards 1","nick":"","place":"","img":"http:\/\/i8.ifrype.com\/profile\/091\/638\/v1\/sm_91638.jpg","imgi":"http:\/\/i8.ifrype.com\/profile\/091\/638\/v1\/i_91638.jpg","imgm":"http:\/\/i8.ifrype.com\/profile\/091\/638\/v1\/nm_91638.jpg","imgl":"http:\/\/i8.ifrype.com\/profile\/091\/638\/v1\/l_91638.jpg","sex":"M","birthday":"1983-11-09","age":29,"adult":1,"type":"User_Default","created":"08.11.2004 14:30:52","deleted":false}}}')
