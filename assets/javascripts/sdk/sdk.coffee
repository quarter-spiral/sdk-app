simplifyValue = (value) ->
  type = typeof value
  if type is 'string' or type is 'number' or type is 'boolean' or value is null
    value
  else if type == 'object'
    "__json__#{JSON.stringify(value)}"
  else
    throw new Error("Can not store a value of type: #{type}")

simplifyData = (data) ->
  simplifiedData = {}
  for key, value of data
    simplifiedData[key] = simplifyValue(value)

  simplifiedData

extractValue = (value) ->
  return value if (typeof value) isnt 'string'
  matchData = value.match(/^__json__(.*)$/)
  if matchData
    json = matchData[1]
    try
      JSON.parse(json)
    catch e
      throw new Error("Invalid JSON data: #{json}")
  else
    value

extractData = (data) ->
  extractedData = {}
  for key, value of data
    extractedData[key] = extractValue(value)
  extractedData


flashMovie = null;
onDomReady ->
  flashMovie = document.getElementById('qs-embedded-flash-game')

class QS
  @defaultOptions: {
    canvasAppUrl: ((window.qsSdk || {}).ENV || {}).QS_CANVAS_APP_URL || 'http://qs-canvas-app.herokuapp.com',
  }

  @setup: (options) ->
    qs = new QS()

    qs.options = aug(@defaultOptions, options)
    deferred = Q.defer()

    if window.qs
      qs.data = window.qs
      if flashMovie and flashMovie.qsSetupCallback
        window.QS.flash = qs
        flashMovie.qsSetupCallback(qs)
        return
      else
        deferred.resolve(qs)

    receiveMessage = (event) ->
      return if event.origin isnt qs.options.canvasAppUrl

      data = JSON.parse(event.data)

      switch data.type
        when 'qs-data'
          event.source.postMessage(JSON.stringify(type: 'qs-info-received'), event.origin);
          qs.data = data.data
          if flashMovie and flashMovie.qsSetupCallback
            window.qsFlashData = qs
            flashMovie.qsSetupCallback(qs)
          else
            deferred.resolve(qs)

    window.addEventListener "message", receiveMessage, false
    deferred.promise

  retrievePlayerInfo: =>
    deferred = Q.defer()
    reqwest(
        url: "#{@data.ENV.QS_AUTH_BACKEND_URL}/api/v1/me"
        type: 'json'
        method: 'get'
        headers: {
          Authorization: "Bearer #{@data.tokens.qs}"
        }
    ).then((player) ->
      if flashMovie && flashMovie.qsPlayerInfoCallback
        flashMovie.qsPlayerInfoCallback(player)
      else
        deferred.resolve(player)
    , (err, msg) ->
      if flashMovie && flashMovie.qsPlayerInfoErrorCallback
        flashMovie.qsPlayerInfoErrorCallback(msg)
      else
        deferred.reject(err)

    )
    deferred.promise

  retrievePlayerData: =>
    deferred = Q.defer()
    reqwest(
        url: "#{@data.ENV.QS_PLAYERCENTER_BACKEND_URL}/v1/#{@data.info.uuid}/games/#{@data.info.game}/meta-data"
        type: 'json'
        method: 'get'
        headers: {
          Authorization: "Bearer #{@data.tokens.qs}"
        }
    ).then((playerData) ->
      data = extractData(playerData.meta)
      if flashMovie && flashMovie.qsPlayerDataCallback
        flashMovie.qsPlayerDataCallback(data)
      else
        deferred.resolve(data)
    , (err, msg) ->
      if flashMovie && flashMovie.qsPlayerDataErrorCallback
        flashMovie.qsPlayerDataErrorCallback(msg)
      else
        deferred.reject(err)

    )
    deferred.promise

  setPlayerData: (keyOrData, value) =>
    deferred = Q.defer()
    type = typeof keyOrData
    switch type
      when  'string'
        data = {}
        key = keyOrData
        data[key] = value
      when 'object'
        data = keyOrData
        key = null
      else
        throw new Error("First argument must be a string or an object")

    url = "#{@data.ENV.QS_PLAYERCENTER_BACKEND_URL}/v1/#{@data.info.uuid}/games/#{@data.info.game}/meta-data"
    url = "#{url}/#{key}" if key

    data = simplifyData(data)

    reqwest(
        url: url
        type: 'json'
        method: 'put'
        data: JSON.stringify(meta: data)
        headers: {
          Authorization: "Bearer #{@data.tokens.qs}"
        }
    ).then((playerData) ->
      if flashMovie && flashMovie.qsPlayerDataSetCallback
        flashMovie.qsPlayerDataSetCallback(playerData)
      else
        deferred.resolve(playerData.meta)
    , (err, msg) ->
      if flashMovie && flashMovie.qsPlayerDataSetErrorCallback
        flashMovie.qsPlayerDataSetErrorCallback(msg)
      else
        deferred.reject(err)
    )
    deferred.promise

@QS = QS