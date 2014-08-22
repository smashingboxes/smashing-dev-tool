required =      require 'require-dir'

module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, vendorFiles, copyFiles, time, filters, dest, colors, $} = helpers
  {logger, notify, execute} = util

  require('../phases/compile/coffee')(project)
  require('../phases/compile/css')(project)
  require('../phases/compile/data')(project)
  require('../phases/compile/html')(project)
  require('../phases/compile/jade')(project)
  require('../phases/compile/js')(project)
  require('../phases/compile/styl')(project)
  require('../phases/compile/vendor')(project)

  commander
    .command('compile')
    .description('compile local assets based on Smashfile')
    .action ->
      toRun = ("compile:#{ext}" for ext, asset of assets)
      tasks.start toRun
