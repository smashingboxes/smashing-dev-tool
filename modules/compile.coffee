required =      require 'require-dir'

{logger, notify, execute} = require '../config/util'
{assets, tasks, args, dir} = require '../config/config'

required '../phases/compile'

module.exports = (commander) ->
  commander
    .command('compile')
    .description('compile local assets based on Smashfile')
    .action ->
      toRun = ("compile:#{ext}" for ext, asset of assets)
      tasks.start toRun
