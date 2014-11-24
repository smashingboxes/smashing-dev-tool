required       = require 'require-dir'
gulp           = require 'gulp'
lazypipe       = require 'lazypipe'
_              = require 'underscore'
merge          = require 'merge-stream'
amdOptimize    = require 'amd-optimize'
bowerRequireJS = require 'bower-requirejs'
del            = require 'del'
chalk          = require 'chalk'
fs             = require 'fs'

module.exports = (globalConfig) ->
  {args, util, tasks, recipes, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute, merge} = util
  {assets, helpers, dir, env} = getProject()
  {files, dest, $, logging, watching} = helpers

  target = null


  # Collect recipe formulae
  for recipe in ['coffee', 'js', 'styl', 'css', 'jade', 'html', 'json', 'vendor', 'images', 'fonts']
    recipes[recipe] = require("../recipes/#{recipe}")(globalConfig)

  # Build required asset tasks based on project Smashfile
  assetTasks = ("#{ext}" for ext, asset of assets).concat ['vendor', 'images']

  # Dynamically generate compile tasks from recipe functions
  runTasks = null
  registerCompileTasks = ->
    runTasks = for ext in assetTasks
      if fn = recipes[ext]?.compile
        task = "compile:#{ext}"
        glob = "#{dir.client}/**/*.#{ext}"
        doReload = assets[ext]?.reload

        tasks.add task, fn                  # Access task via our Orchestrator instance
        if args.watch
          gulp.task task, fn                 # Access task via Gulp's Orchestrator instance
          gulp.watch glob, (if doReload then [task, $.reload] else [task])  # Reload when watching

        task


  ### ---------------- COMMANDS ------------------------------------------- ###
  commander
    .command('compile')
    .alias('c')
    .option('-w, --watch', 'Watch files and recompile on change')
    .option('-r --reload', 'Reload the browser on change')
    .option('-c --cat', 'Output injected index file for inspection')
    .description('compile local assets based on Smashfile')
    .action (_target) ->
      target = _target
      toRun = ['compile']
      toRun.push 'compile:serve'  if args.watch
      tasks.start toRun



  ### ---------------- TASKS ---------------------------------------------- ###
  # Clear previous compile results and compile all assets
  tasks.add 'compile:assets', ['compile:clean'], ->
    registerCompileTasks()

    logger.info "Compiling assets..."  if args.verbose

    app = merge(
      recipes.coffee.compile()
      recipes.js.compile()
      recipes.styl.compile()
      recipes.css.compile()
      recipes.html.compile()
      recipes.jade.compile()
      recipes.vendor.compile()
    )

  tasks.add 'compile', ['compile:assets'],  ->
    injectIndex = ->
      logger.info "Injecting compiled files into #{chalk.magenta 'index.jade'}"  if args.verbose

      files path:"#{dir.client}/index.jade"
        .pipe logging()

        # Inject CSS, inject JS
        .pipe $.inject files('compile', ['.css', '.js'], false),
          name:'app', ignorePath:'compile', addRootSlash:false

        # Inject vendor files
        .pipe $.inject files('vendor', '*', false),
          name:'vendor', ignorePath:'client', addRootSlash:false

        # Display injected output in console
        .pipe $.if args.cat, $.cat()

        # Compile Jade to HTML
        .pipe $.jade pretty:true, compileDebug:true
        .on('error', (err) -> logger.error err.message)

        # Output HTML
        .pipe dest.compile()

    if args.watch
      gulp.task 'inject:index', injectIndex
      gulp.watch "#{dir.client}/index.jade", ['inject:index', $.reload]

    injectIndex()


  # Compile assets and watch source for changes, recompiling on event
  tasks.add 'compile:serve', ->
    setTimeout (->
      $.browserSync
        server:
          baseDir:          dir.compile
        watchOptions:
          debounceDelay:  100
        logPrefix:      'BrowserSync'
        logConnections: true
        logFileChanges: true
        # logLevel:     'debug'
        port:           8080

    ), 5000


  # Remove previous compilation
  tasks.add 'compile:clean', (done) ->
    if fs.existsSync dir.compile
      logger.info "Deleting #{chalk.magenta './'+dir.compile}"
      del [dir.compile], done
    else
      done()
