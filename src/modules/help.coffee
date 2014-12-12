
smasher = require '../config/global'

smasher.module
  name:     'help'
  commands: ['help']
  init: (smasher) ->
    smasher.commander
      .option('-v, --verbose',         'Display detailed log information')
      .option('-s, --silent',          'Hide all logs and notifications')
      .on '--help', ->
        console.log '  Examples:'
        console.log ''
        console.log '    $ smash generate app my-new-app'
        console.log '    $ smash generate component base/header'
        console.log ''
