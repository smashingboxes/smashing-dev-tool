gulp  = require 'gulp'
_     = require 'lodash'
del   = require 'del'
chalk = require 'chalk'
fs    = require 'fs'
q     = require 'q'


module.exports = (Smasher) ->
  {recipes, commander, recipes,  project, util, helpers} = Smasher
  {logger, notify, execute, merge, args} = util
  {files, $, dest, logging,rootPath, pkg} = helpers
  {dir, assets, supportedAssets} = project

  target = null
  compileTasks = ['compile:assets', 'compile:index']
  compileStream = null

  Smasher.on 'clean', -> Smasher.startTask 'compile:clean'


  ### ---------------- COMMANDS ------------------------------------------- ###
  Smasher.command
    cmd: 'compile'
    alias: 'c'
    options: [
      opt: '-c --cat'
      description: 'Output injected index file for inspection'
    ]
    description: 'compile local assets based on Smashfile'
    action: (_target) ->
      target = _target
      compileTasks.push 'compile:serve'  if args.watch
      Smasher.startTask compileTasks

  ### ---------------- TASKS ---------------------------------------------- ###
  # Compile assets and start server
  Smasher.task 'compile', ['compile:index'], (done) ->
    Smasher.startTask 'compile:serve'

  # Injects assets into index.jade and compiles
  Smasher.task 'compile:index', ['compile:assets'], ->
    injectIndex = ->
      logger.info "Injecting compiled files into #{chalk.magenta 'index.jade'}"

      vendorFiles = files('vendor', '*', false)
        .pipe $.order(project.build.scripts.order)
      appFiles = merge [
        files('compile', '.js', true) #.pipe $.angularFilesort()
        files('compile', '.css', false)
      ]

      files path:"#{dir.client}/index.jade"
        .pipe logging()
        .pipe $.inject appFiles,
          name:         'app'
          ignorePath:   'compile'
          addRootSlash: false
        .pipe $.inject vendorFiles,
          name:         'vendor'
          ignorePath:   'client'
          addRootSlash: false
        .pipe $.if args.cat, $.cat()
        .pipe $.jade pretty:true, compileDebug:true
        .on('error', (err) -> logger.error err.message)
        .pipe dest.compile()
        .pipe $.reload stream:true

    if args.watch
      gulp.task 'inject:index:compile', injectIndex
      gulp.watch "#{dir.client}/index.jade", ['inject:index:compile']

    injectIndex()

  # Clear previous compile results and compile all assets
  Smasher.task 'compile:assets', ['compile:clean'], ->
    logger.info "Compiling assets from #{chalk.green './'+dir.client} to #{chalk.magenta './'+dir.compile}"

    toCompile = _
      .chain supportedAssets
      .intersection assets
      .value()

    # source code recipes
    ax = for asset in toCompile
      recipes[asset].watch() if args.watch
      recipes[asset].compile()

    # vendor/data/non-transform recipes
    bx = for asset in ['vendor', 'images', 'fonts']
      recipes[asset].compile()

    # Copy additional files
    toMerge = []
    toCopy = project.compile?.copy
    if toCopy?
      c = for cp in toCopy
        k = (_.keys cp)[0]
        v = (_.values cp)[0]
        toMerge.push (gulp.src(k).pipe($.flatten()).pipe gulp.dest "#{dir.compile}/#{v}")

    # merge for joint 'end' event
    toMerge.push merge ax
    toMerge.push merge bx
    merge toMerge
      .pipe $.using()

  # Compile assets and watch source for changes, recompiling on event
  Smasher.task 'compile:serve', ->
    $.browserSync
      server:
        baseDir:          dir.compile
      watchOptions:
        debounceDelay:  100
      logPrefix:      'BrowserSync'
      # logConnections: true
      # logFileChanges: true
      # logLevel:     'debug'
      port:           8080
      open: if args.mute then false else true

  # Remove previous compilation
  Smasher.task 'compile:clean', (done) ->
    if fs.existsSync dir.compile
      logger.info "Deleting #{chalk.magenta './'+dir.compile}"
      del [dir.compile], done
    else
      done()
