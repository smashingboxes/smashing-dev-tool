required =      require 'require-dir'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  require('../phases/compile/coffee')(globalConfig)
  require('../phases/compile/css')(globalConfig)
  require('../phases/compile/data')(globalConfig)
  require('../phases/compile/html')(globalConfig)
  require('../phases/compile/jade')(globalConfig)
  require('../phases/compile/js')(globalConfig)
  require('../phases/compile/styl')(globalConfig)
  require('../phases/compile/vendor')(globalConfig)

  commander
    .command('compile')
    .alias('c')
    .description('compile local assets based on Smashfile')
    .action ->
      {assets} = getProject()
      
      toRun = ("compile:#{ext}" for ext, asset of assets)
      tasks.start toRun
