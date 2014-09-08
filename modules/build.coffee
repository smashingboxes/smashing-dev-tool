
module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  require('../phases/build/data')(globalConfig)
  require('../phases/build/images')(globalConfig)
  require('../phases/build/scripts')(globalConfig)
  require('../phases/build/styles')(globalConfig)
  require('../phases/build/vendor')(globalConfig)
  require('../phases/build/views')(globalConfig)

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
