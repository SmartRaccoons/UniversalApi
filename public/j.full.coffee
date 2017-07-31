GET = ((a)->
  b = {}
  if a is ''
    return b
  for pr in a
    p = pr.split('=')
    if p.length is 2
      b[p[0]] = decodeURIComponent(p[1].replace(/\+/g, " "))
  b
)(window.location.search.substr(1).split('&'))

_GET = (p)->
  if p of GET
    return GET[p]
  return false

window.UniversalApi = class UniversalApi
  url: 'http://uniapi.raccoons.lv/user.json'
  # url: 'http://localhost:1234/user.json'

  constructor: (params)->
    @_url_params = params
    if _GET('dr_auth_code')
      @_url_params['dr_auth_code'] = _GET('dr_auth_code')

  _url: (additional = {})->
    url = []
    for k, v of @_url_params
      url.push "#{k}=#{decodeURIComponent(v)}"
    for k, v of additional
      url.push "#{k}=#{decodeURIComponent(v)}"
    url.join('&')

  authorize: (callback)->
    @_request(callback)

  session: -> @_url_params.session

  data: (k, v=false)->
    if v
      additional = {}
      additional["data.#{k}"] = v
      return @_request((->), additional)
    if @user
      return @user.data[k]
    return false

  _request: (callback, additional={})->
    $.ajax({
      url: "#{@url}?#{@_url(additional)}"
      dataType: 'jsonp'
      success: (data)=>
        if data.session
          @_url_params['session'] = data.session
          @user = data
        callback(data)
      error: ->
        callback({})
    })
