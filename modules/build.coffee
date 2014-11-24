gulp =      require 'gulp'
del =       require 'del'
chalk =     require 'chalk'
streamqueue = require 'streamqueue'
fs =        require 'fs'


module.exports = (globalConfig) ->
  {args, util, tasks, recipes, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute, merge} = util
  {assets, helpers, dir, env} = getProject()
  {vendorFiles, mainFile, compiledFiles, files, dest, $} = helpers
  logging = -> $.if args.verbose, $.using()

  target = null
  project = getProject()


  ### ---------------- COMMANDS ------------------------------------------- ###
  commander
    .command('build [target]')
    .description('build local assets for production based on Smashfile')
    .action (_target) ->
      target = _target
      tasks.start 'build'


  ### ---------------- TASKS ------------------------------ ---------------- ###
  tasks.add 'build', ->

    # determine correct output path
    outDir = null
    if target? and project.build?[target]?
      outDir = project.build[target].out
      logger.info "Building files from #{chalk.green './'+project.dir.compile} to #{chalk.magenta './'+outDir} for target #{chalk.bold target}"
    else
      outDir = project.dir.build
      logger.info "Building files from #{chalk.green './'+project.dir.compile} to #{chalk.magenta './'+outDir}"

    # Conert app Views to JS
    views = files('compile', '.html')
      .pipe $.htmlmin collapseWhitespace: true
      .pipe $.ngHtml2js moduleName: 'templates-main'
      .pipe $.concat 'templates-main.js'

    # Merge vendor and app Scripts, optimize
    scripts = merge(
      files('compile', '.js').pipe($.ngAnnotate())
      files('vendor', '.js')
      views
    ).pipe($.uglify()).pipe($.concat 'app.js')


    # Optimize and output Images
    images = files path:'client/data/images', ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg']
      .pipe $.imagemin()
      .pipe gulp.dest "#{outDir}/images"
      .pipe logging()

    # Optimize and output Fonts
    fonts = files path:'client/data/fonts', ['.eot', '.svg', '.ttf', '.woff']
      .pipe gulp.dest "#{outDir}/fonts"
      .pipe logging()

    # Merge vendor and app Styles, optimize
    styles = merge(
      files('compile', '.css')
      files('vendor', '.css')
    ).pipe($.concat 'app-styles.css').pipe $.csso()

    # Output Scripts and Styles to build directory
    pkg = merge(scripts, styles)
      .pipe gulp.dest outDir
      .pipe logging()


    # Inject built files into index.html
    files 'index.jade'
      .pipe $.using()
      .pipe $.inject pkg,
        name: 'app'
        ignorePath: 'build'
        addRootSlash: false
      .pipe logging()

      # convert to HTML and optimize
      .pipe $.jade()
      .on('error', (err) -> logger.error err.message)
      .pipe $.htmlmin collapseWhitespace: true

      .pipe $.if args.verbose, $.cat()
      .pipe gulp.dest outDir


  tasks.add 'build:watch', ->
    args.watch = true


  tasks.add 'build:clean', (done) ->
    hasDirs = false

    if project.build?
      hasDirs = true
      for t of project.build
        if fs.existsSync project.build[t].out
          logger.info "Deleting #{chalk.magenta './'+project.build[t].out}"
          del [project.build[t].out]

    if fs.existsSync project.dir.build
      hasDirs = true
      logger.info "Deleting #{chalk.magenta './'+project.dir.build}"
      del [project.dir.build], done

    done() unless hasDirs
