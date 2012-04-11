{Tailer} = require('./tailer')
redis = require('redis')

exports.run = ->
  if !process.env.DB_PATH || !process.env.REDIS_CHANNEL
    console.info "Usage:"
    console.info "DB_PATH='[/data/twitter/]YYYY/MM/[twitter].YYYYMMDDHH[.jsons]' REDIS_CHANNEL=twitter"+process.argv[1]
    process.exit(-1)

  setInterval ->
    console.log process.memoryUsage()
    if process.memoryUsage().rss > 1.0*1024*1024*1024
      console.log "EXCEED MEMORY LIMIT. TERMINATING..."
      process.exit(1)
  , 10000

  tailer = new Tailer(process.env.DB_PATH)

  tailer.on 'open', (path) ->
    console.log 'opening ' + path

  tailer.on 'tail-exit', ->
    console.log 'tail exited'

  tailer.on 'tail-kill', (path) ->
    console.log 'killing tail for ' + path

  tailer.on 'stats', (stats) ->
    console.log("#{stats.numReceived} tweets, #{stats.tps.toFixed(1)} TPS")

  channel = process.env.REDIS_CHANNEL
  host = process.env.REDIS_HOST || '127.0.0.1'
  port = process.env.REDIS_PORT || 6379
  password = process.env.REDIS_PASSWORD
  console.log "Connecting to Redis on %s:%s", host, port
  client = redis.createClient(port, host)

  if password?
    console.info "Setting Redis password"
    client.auth(password)

  client.on 'error', (error) ->
    console.warn 'Redis connection error: %s', error

  client.on 'connect', ->
    console.info 'Redis connected'

  console.info "Messages are directed to channel '%s'", channel

  tailer.on 'data', (json) ->
    client.publish(channel, json)

  tailer.start()
