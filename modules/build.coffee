gulp =      require 'gulp'
del =       require 'del'
chalk =     require 'chalk'
streamqueue = require 'streamqueue'


module.exports = (globalConfig) ->
  {args, util, tasks, fileRecipes, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute, merge} = util
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

      images = files path:'client/data/images', ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg']
        # .pipe $.imagemin()
        .pipe gulp.dest "#{targetOpts.out}/images"
        .pipe $.using()

      fonts = files path:'client/data/fonts', ['.eot', '.svg', '.ttf', '.woff']
        .pipe gulp.dest "#{targetOpts.out}/fonts"
        .pipe $.using()

      styles = merge(
        files('compile', '.css')
        files('vendor', '.css')
      )
        .pipe $.concat('app-styles.css')
        .pipe $.csso()

      views = files('compile', '.html')
        .pipe $.ngHtml2js(moduleName: 'templates-main')
        .pipe $.concat('templates-main.js')

      scripts = merge(
        files('compile', '.js').pipe($.ngAnnotate())
        files('vendor', '.js')
      )
        .pipe $.concat 'scripts-main.js'

      scriptsPkg = merge(scripts, views)
        .pipe $.uglify()
        .pipe $.concat 'app.js'


      pkg = merge(scriptsPkg, styles)
        .pipe gulp.dest targetOpts.out
        .pipe $.if args.verbose, $.using()

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
