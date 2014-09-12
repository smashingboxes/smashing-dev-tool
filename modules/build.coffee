gulp =      require 'gulp'


module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  require('../phases/build/data')(globalConfig)
  require('../phases/build/images')(globalConfig)
  require('../phases/build/scripts')(globalConfig)
  require('../phases/build/styles')(globalConfig)
  require('../phases/build/vendor')(globalConfig)
  require('../phases/build/views')(globalConfig)

  tasks.add 'build:watch', ->
    globalConfig.watching = true
    tasks.start [
      'build:scripts'
      'build:styles'
      'build:vendor'
      'build:views'
      'build:data'
      'build:images'
    ]


  tasks.add 'build:clean', ->
    {assets, helpers, dir} = getProject()
    $ = helpers.$
    gulp.src dir.build
      .pipe $.using()
      .pipe $.rimraf force:true, read:false

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
