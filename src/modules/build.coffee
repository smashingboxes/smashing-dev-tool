gulp    = require 'gulp'
_       = require 'lodash'
del     = require 'del'
chalk   = require 'chalk'
fs      = require 'fs'

module.exports = (Smasher) ->
  {commander, assumptions, user, platform, project, recipes, util, helpers} = Smasher
  {logger, notify, execute, merge, args} = util
  {files, $, dest, onError, rootPath, pkg, logging} = helpers
  {dir} = project

  target        = project.dir?.build
  buildOpts     = null
  buildTasks    = null
  includeVendor = null
  includeIndex  = null

  cfg =
    ngAnnotate:
      remove: true
      add: true
      single_quote: true
    uglify:
      mangle: true
      preserveComments: 'some'

  Smasher.on 'clean', -> Smasher.startTask 'build:clean'

  ### ---------------- COMMANDS ------------------------------------------- ###
  Smasher.command
    cmd: 'build [target]'
    alias: 'b'
    description: 'build local assets for production based on Smashfile'
    options: [
      opt: '-c --cat'
      description: 'Output injected index file for inspection'
    ]
    action: (_target) ->
      buildOpts     = project.build or {}
      target        = buildOpts.out or project.dir.build
      includeVendor = if buildOpts.includeVendor? then buildOpts.includeVendor else true
      includeIndex  = if buildOpts.includeIndex? then buildOpts.includeIndex else true

      buildTasks = if includeIndex then ['build:index']
      else ['build:assets']
      Smasher.startTask buildTasks


  ### ---------------- TASKS ---------------------------------------------- ###
  # Build assets and start server
  Smasher.task 'build', ['build:index'], (done) ->
    Smasher.startTask 'build:serve'

  # Build assets from compiled source
  Smasher.task 'build:assets', ['build:clean', 'compile:assets'], ->
    JSoutfile  = recipes.js.getOutFile()
    CSSoutfile = recipes.css.getOutFile()

    target ?= 'build'
    logger.info "Building assets from #{chalk.magenta './'+dir.compile} to #{chalk.red './'+target}"


    # app css + vendor css => js
    css = merge [
      files('vendor', '.css', true)
        .pipe $.order(project.build.styles.order)
        .pipe $.concat('app-vendor.css')
      recipes['css'].build(false)
    ]
      .pipe $.order(['app-vendor.css', 'app-styles.css'])
      .pipe $.concat CSSoutfile
      .pipe $.cssmin()
      .pipe $.css2js()

    # css.js + html.js + app.js  (? vendor.js)
    _js = [
      recipes['html'].build(false)
      recipes['js'].build(false)
      css
    ]
    _js.push files('vendor', '.js')  if includeVendor

    # app js + vendor js
    js = merge _js
      .pipe $.order project.build.scripts.order
      .pipe $.concat JSoutfile
      .pipe $.uglify cfg.uglify
      .pipe $.if args.cat, $.cat()

    merge [
      recipes.images.build()
      recipes.fonts.build()
      js
    ]
      .pipe $.plumber()
      .pipe gulp.dest target


  Smasher.task 'build:index', ['build:assets'],  ->
    logger.verbose "Injecting built files into #{chalk.magenta 'index.jade'}"
    appFiles = merge [
      files('build', '.js', true)
      files('build', '.css', false)
    ]

    files path:"#{dir.client}/index.jade"
      .pipe logging()

      .pipe $.inject appFiles,
        name:         'app'
        ignorePath:   'build'
        addRootSlash: false

      .pipe $.if args.cat, $.cat()

      .pipe $.jade compileDebug:true
      .on('error', (err) -> logger.error err.message)

      .pipe gulp.dest target
      .pipe logging()


  Smasher.task 'build:serve', ->
    $.browserSync
      server:
        baseDir:       target
      watchOptions:
        debounceDelay:  100
      logPrefix:      'BrowserSync'
      logConnections: args.verbose
      logFileChanges: args.verbose
      # logLevel:     'debug'
      port:           8080


  Smasher.task 'build:clean', (done) ->
    toDelete = []
    if fs.existsSync dir.build
      logger.info "Deleting #{chalk.magenta './'+dir.build}"
      del [dir.build], done
    else if fs.existsSync project.build.out
      logger.info "Deleting #{chalk.magenta './'+project.build.out}"
      del [project.build.out], done
    else
      done()
