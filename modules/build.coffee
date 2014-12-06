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

target = dir.build
buildOpts = null
buildTasks = ['build:assets']


### ---------------- COMMANDS ------------------------------------------- ###
smasher.command('build [target]')
  .description('build local assets for production based on Smashfile')
  .option('-c --cat', 'Output injected index file for inspection')
  .action (_target) ->
    buildOpts = project.build?[_target] or {}
    target = buildOpts?.out or dir.build
    tasks.start buildTasks


### ---------------- TASKS ---------------------------------------------- ###
smasher.task 'build:assets', ['build:clean', 'compile:assets'], ->
  logger.info "Building assets from #{chalk.magenta './'+project.dir.compile} to #{chalk.red './'+target}"
  logger.verbose 'Building assets...'
  merge(
    recipes.js.build()
    recipes.css.build()
    recipes.html.build()

    recipes.images.build()
  )

smasher.task 'build:index', ->
  logger.info "Building index file..."  if args.verbose
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
      .pipe gulp.dest target
      .pipe logging()
      .pipe watching()

  if args.watch
    gulp.task 'inject:index', injectIndex
    gulp.watch "#{dir.client}/index.jade", ['inject:index']

  injectIndex()

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
  toDelete = _.chain(project.build)
    .pluck 'out'
    .concat [dir.build]
    .filter ((path) -> fs.existsSync path)
    .value()

  if toDelete.length
    logger.info "Deleting #{chalk.magenta ('./'+d for d in toDelete).join(', ')}"
    del toDelete, done
  else done()
