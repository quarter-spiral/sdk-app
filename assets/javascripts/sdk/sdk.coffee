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

flashMovie = null
dataFromCanvas = null
resolvedData = null

resolveQsData = (handler) ->
  newData = window.qs || dataFromCanvas
  handler(newData) if !resolvedData and newData
  resolvedData = newData
  setTimeout((-> resolveQsData(handler)), 100) unless resolvedData

class QS
  @defaultOptions: {
    canvasAppUrl: ((window.qsSdk || {}).ENV || {}).QS_CANVAS_APP_URL || 'http://qs-canvas-app.herokuapp.com',
  }

  @log: (msg) ->
    console.log("From Flash:", msg)

  @setup: (options) ->
    qs = new QS()

    qs.options = aug(@defaultOptions, options)
    deferred = Q.defer()

    flashMovie = document.getElementById('qs-embedded-flash-game')

    resolveQsData (data) ->
      # return when no QS token is present (a.k.a. not logged in user)
      if !data.tokens or !data.tokens.qs
        if flashMovie and flashMovie.qsSetupErrorCallback
          flashMovie.qsSetupErrorCallback("Not logged in")
        else
          error = new Error("Not logged in")
          error.data =  data
          deferred.reject(error)
        return

      qs.data = data
      if flashMovie and flashMovie.qsSetupCallback
        window.qsFlashData = qs
        window.QS.flash = qs
        flashMovie.qsSetupCallback(qs)
      else
        deferred.resolve(qs)

    deferred.promise

  retrieveLoggedInPlayerInfo: =>
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

  retrievePlayerInfo: (uuids) =>
    return @retrieveLoggedInPlayerInfo() unless uuids

    clearTimeout(@retrievePlayerInfoTimeout) if @retrievePlayerInfoTimeout

    @retrievePlayerInfoUuids ||= []
    @retrievePlayerInfoDeferred ||= Q.defer()

    uuids = [uuids] if (typeof uuids) is 'string'
    @retrievePlayerInfoUuids.push(uuid) for uuid in uuids when @retrievePlayerInfoUuids.indexOf(uuid) < 0
    deferred = @retrievePlayerInfoDeferred

    @retrievePlayerInfoTimeout = setTimeout(=>
      uuids = if @retrievePlayerInfoUuids.length > 0 then "uuids[]=#{@retrievePlayerInfoUuids.join('&uuids[]=')}" else ''
      @retrievePlayerInfoUuids = []
      @retrievePlayerInfoDeferred = null
      reqwest(
          url: "#{@data.ENV.QS_PLAYERCENTER_BACKEND_URL}/v1/public/players?#{uuids}"
          type: 'json'
          method: 'get'
      ).then((playerInfo) ->
        deferred.resolve(playerInfo)

      , (err, msg) ->
        if flashMovie && flashMovie.qsPlayerDataErrorCallback
          flashMovie.qsPlayerDataErrorCallback(msg)
        else
          deferred.reject(err)
      )
    , 500)

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
        contentType: 'application/json'
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

domready(->
  canvasFrame = window.parent;

  messageHandler = (event) ->
    #return if event.origin isnt qs.options.canvasAppUrl
    data = null
    try
      data = JSON.parse(event.data)
    catch e
        return

    switch data.type
      when 'qs-data'
        if data.data
          event.source.postMessage(JSON.stringify(type: 'qs-info-received'), event.origin)
          dataFromCanvas = data.data



  window.addEventListener "message", messageHandler, false

  signalGameLoad = ->
    unless dataFromCanvas
      canvasFrame.postMessage(JSON.stringify(type: 'qs-game-loaded'), '*');
      setTimeout(signalGameLoad, 300);

  signalGameLoad()
)