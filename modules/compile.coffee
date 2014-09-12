required =      require 'require-dir'
gulp =          require 'gulp'

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
    .option('-w, --watch', 'Watch files and recompile on change')
    .description('compile local assets based on Smashfile')
    .action ->
      {assets, helpers, dir} = getProject()
      {vendorFiles, $} = helpers
      vendorFiles('*')
        .pipe($.using())
        .pipe(gulp.dest "#{dir.compile}/components/vendor")
      tasks.start ("compile:#{ext}" for ext, asset of assets)


  tasks.add 'compile:watch', ->
    {assets, helpers, dir} = getProject()
    {vendorFiles, $} = helpers
    vendorFiles('*')
      .pipe($.using())
      .pipe(gulp.dest "#{dir.compile}/components/vendor")

    globalConfig.watching = true
    tasks.start ("compile:#{ext}" for ext, asset of assets)


  tasks.add 'compile:clean', ->
    {assets, helpers, dir} = getProject()
    $ = helpers.$

    gulp.src dir.compile
      .pipe $.using()
      .pipe $.rimraf force:true, read:false
