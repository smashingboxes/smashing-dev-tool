required =      require 'require-dir'

{logger, notify, execute} = require '../config/util'
{assets, tasks, args, dir} = require '../config/config'

required '../phases/build'


module.exports = (commander) ->

  commander
    .command('build')
    .description('build local assets based on Smashfile')
    .action ->
      tasks.start [
        'build:scripts'
        'build:styles'
        'build:vendor'
        'build:views'
        'build:data'
        'build:images'
      ]
