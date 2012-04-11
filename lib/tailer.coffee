moment = require('moment')
{EventEmitter} = require('events')
{spawn} = require('child_process')

class Tailer extends EventEmitter
  constructor: (@storagePath, @callback) ->
    @currentFile = null
    @numReceived = 0
    @lastChecked = new Date()

  pathForTime: (t) ->
      moment(t).utc().format(@storagePath)

  stats: =>
    now = new Date()
    tps = @numReceived / ((now - @lastChecked) / 1000)
    @emit 'stats', {numReceived: @numReceived, tps: tps}
    @numReceived = 0
    @lastChecked = now

  start: ->
    setInterval @stats, 2000

    tailf = null
    setInterval =>
      t = new Date()
      filePath = @pathForTime(t)

      if @currentFile? && @currentFile != filePath
        @emit 'tail-kill', @currentFile
        tailf.kill()

      unless @currentFile
        @emit 'open', filePath
        tailf = spawn("tail", ["-n", 100, "-f", filePath])
        @currentFile = filePath
        buffer = ''
        tailf.stdout.on "data", (data) =>
          buffer += data
          while((index = buffer.indexOf('\n')) > -1)
            json = buffer.slice(0, index).replace(/(\n|\r)+$/, '');
            buffer = buffer.slice(index + 1)
            @emit 'data', json
            @numReceived += 1

        tailf.on 'exit', (code) =>
          @currentFile = null
          @emit 'tail-exit'
    , 1000

exports.Tailer = Tailer
