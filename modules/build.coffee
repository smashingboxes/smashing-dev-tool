
module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, vendorFiles, copyFiles, time, filters, dest, colors, $} = helpers
  {logger, notify, execute} = util

  require('../phases/build/data')(project)
  require('../phases/build/images')(project)
  require('../phases/build/scripts')(project)
  require('../phases/build/styles')(project)
  require('../phases/build/vendor')(project)
  require('../phases/build/views')(project)

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
