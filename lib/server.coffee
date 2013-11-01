{Tailer} = require('./tailer')
amqp = require('amqp')

exports.run = ->
  if !process.env.DB_PATH || !process.env.AMQP_EXCHANGE_NAME
    console.info "Usage:"
    console.info "DB_PATH='[/data/twitter/]YYYY/MM/[twitter].YYYYMMDDHH[.jsons]' AMQP_EXCHANGE_NAME=twitter "+process.argv[1]
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

  url = process.env.AMQP_URL
  exchangeName = process.env.AMQP_EXCHANGE_NAME
  amqpConnection = amqp.createConnection(url: url, reconnect: true)
  amqpConnection.on 'ready', ->
    console.log 'AMQP ' + url + ' ready'
    amqpConnection.exchange exchangeName, type: 'fanout', (exchange) ->
      console.log 'Exchange ' + exchange.name + ' is ready'
      tailer.on 'data', (json) ->
        exchange.publish '', json, contentType: 'text/json'

  tailer.start()
