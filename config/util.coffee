winston =       require 'winston'
notifier =      require 'node-notifier'
exec =          require('child_process').exec   # execute commands
streamqueue =   require 'streamqueue'

# winston logger config
winston.cli()
logger = exports.logger = new (winston.Logger)(
  transports: [new (winston.transports.Console)(colorize: true, level: 'info')]
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
n = new notifier()
notify = exports.notify = (title, message, type) ->
  msg =
    title: title
    message: message
    group: type
  n.notify msg
  logger.info msg.message


# execute cli commands
execute = exports.execute = (command, cb)->
  exec command, (err, stdout, stderr) ->
    console.log stdout
    cb err

# Returns a new stream composed of all argument streams
merge = exports.merge = (streams...) ->
  queue = new streamqueue objectMode:true
  queue.done.apply queue, streams
