gulp =      require 'gulp'
del =       require 'del'
chalk =     require 'chalk'


module.exports = (globalConfig) ->
  {args, util, tasks, fileRecipes, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util
  {assets, helpers, dir, env} = getProject()
  {vendorFiles, mainFile, compiledFiles, files, dest, $} = helpers

  target = null
  project = getProject()


  ### ---------------- COMMANDS ------------------------------------------- ###
  commander
    .command('build [target]')
    .description('build local assets for production based on Smashfile')
    .action (_target) ->
      target = _target
      tasks.start 'build'

      # tasks.start [
      #   'build:scripts'
      #   'build:styles'
      #   'build:vendor'
      #   'build:views'
      #   'build:data'
      #   'build:images'
      # ]


  ### ---------------- TASKS ------------------------------ ---------------- ###
  tasks.add 'build', ->
    if target? and project.build?[target]?

      targetOpts = project.build[target]
      logger.info "building files from #{chalk.red.bold './'+project.dir.compile} to #{chalk.magenta.bold './'+targetOpts.out} for target #{chalk.green.bold target}"
      files('compile', '.html')
        .pipe $.ngHtml2js(moduleName: 'templates-main')
        .pipe $.concat('templates-main.js')
        .pipe gulp.dest targetOpts.out
    else
      logger.info "building files from #{chalk.red.bold './'+project.dir.compile} to #{chalk.magenta.bold './'+project.dir.build}"
      files('compile', '.html')
        .pipe $.using()
        .pipe dest.build()

  tasks.add 'build:watch', ->
    args.watch = true
    # tasks.start [
    #   'build:scripts'
    #   'build:styles'
    #   'build:vendor'
    #   'build:views'
    #   'build:data'
    #   'build:images'
    # ]

  tasks.add 'build:clean', (done) ->
    if project.build?
      for t of project.build
        console.log project.build[t].out
        del [project.build[t].out]
    else
      del [project.dir.build], done
