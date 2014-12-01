gulp    = require 'gulp'
_       = require 'lodash'
del     = require 'del'
chalk   = require 'chalk'
fs      = require 'fs'

smasher = require '../config/global'
project = require '../config/project'
util    = require '../utils/util'
helpers = require '../utils/helpers'

{args, tasks, recipes, commander, assumptions, rootPath, user, platform, project} = smasher
{assets, dir, env} = project
{logger, notify, execute, merge} = util
{files, dest, $, logging, watching} = helpers

target = null


### ---------------- COMMANDS ------------------------------------------- ###
smasher.command('build [target]')
  .description('build local assets for production based on Smashfile')
  .option('-c --cat', 'Output injected index file for inspection')
  .action (_target) ->
    target = _target
    toRun = ['build']
    toRun.push 'build:serve'  if args.watch
    tasks.start toRun


### ---------------- TASKS ------------------------------ ---------------- ###
smasher.task 'build', ['build:assets'], ->
  # Determine correct output path
  outDir = null
  if target? and project.build?[target]?
    outDir = project.build[target].out
    logger.info "Building files from #{chalk.green './'+project.dir.compile} to #{chalk.magenta './'+outDir} for target #{chalk.bold target}"
  else
    outDir = project.dir.build
    logger.info "Building files from #{chalk.green './'+project.dir.compile} to #{chalk.magenta './'+outDir}"

  injectIndex = ->
    logger.info "Injecting built files into #{chalk.magenta 'index.jade'}"  if args.verbose

    files path:"#{dir.client}/index.jade"
      .pipe logging()

      # Inject CSS, inject JS
      .pipe $.inject files('build', ['.css', '.js'], false),
        name:'app', ignorePath:'build', addRootSlash:false

      # Display injected output in console
      .pipe $.if args.cat, $.cat()

      # Compile Jade to HTML
      .pipe $.jade compileDebug:true
      .on('error', (err) -> logger.error err.message)

      .pipe $.if args.cat, $.cat()

      # Output HTML
      .pipe gulp.dest outDir
      .pipe logging()
      .pipe watching()

  if args.watch
    gulp.task 'inject:index', injectIndex
    gulp.watch "#{dir.client}/index.jade", ['inject:index']

  injectIndex()

smasher.task 'build:assets', ['build:clean'], ->
  logger.info "Building assets..."  if args.verbose
  merge.apply @, (r.build()  for r in _.values recipes)

smasher.task 'build:serve', ->
  setTimeout (->
    $.browserSync
      server:
        baseDir:          dir.build
      watchOptions:
        debounceDelay:  100
      logPrefix:      'BrowserSync'
      logConnections: args.verbose
      logFileChanges: args.verbose
      # logLevel:     'debug'
      port:           8080
  ), 5000

smasher.task 'build:clean', (done) ->
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
