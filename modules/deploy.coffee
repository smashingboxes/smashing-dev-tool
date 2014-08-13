required =      require 'require-dir'

{logger, notify, execute} = require '../config/util'
{assets, tasks, args, dir} = require '../config/config'

required '../phases/compile'

module.exports = (commander) ->
  commander
    .command('deploy')
    .description('compile local assets based on Smashfile')
    .action ->
      logger.info 'Deploying App'
