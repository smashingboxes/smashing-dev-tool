winston     = require 'winston'
notifier    = require 'node-notifier'
exec        = require('child_process').exec
streamqueue = require 'streamqueue'
args        = require('minimist')(process.argv.slice 2)
spawn         = require('child_process').spawn


module.exports = (Registry) ->

  # winston logger config
  winston.cli()
  logger = new (winston.Logger)(
    transports: [new (winston.transports.Console)(colorize: true, level: (if args.verbose then 'verbose' else 'info'))]
    levels:
      silly: 0
      verbose: 1
      info: 2
      data: 3
      warn: 4
      debug: 5
      error: 6
    colors:
      silly: 'magenta'
      verbose: 'cyan'
      info: 'green'
      data: 'grey'
      warn: 'yellow'
      debug: 'blue'
      error: 'red'
  )

  # configure notifications
  notify = (title, message, type) ->
    msg =
      title: title
      message: message
      group: type
    notifier.notify msg
    logger.verbose msg.message

  # execute cli commands
  execute = (command, cb) ->
    command = command.split(' ')
    cmd     = spawn command.shift(), command
    cmd.stdout.on 'data', (data) -> console.log data?.toString()
    cmd.stderr.on 'data', (data) -> console.error data?.toString()
    cmd.on 'exit', (code) ->
      logger.verbose 'execute(): child process exited with code ' + code
      cb?()

  # Returns a new stream composed of all argument streams
  merge = (streams) ->
    # if typeof streams isnt 'array'
    #   streams = [streams]

    queue = new streamqueue objectMode:true
    for stream in streams
      queue.queue stream
    queue.done()

  util =
    args:    args
    notify:  notify
    execute: execute
    merge:   merge
    logger:  logger

  Registry.register 'util', util,
    type: 'static'
