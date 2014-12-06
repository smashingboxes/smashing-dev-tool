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
compileTasks = ['compile:assets', 'compile:index']


### ---------------- COMMANDS ------------------------------------------- ###
smasher.command('compile')
  .alias('c')
  .option('-w, --watch', 'Watch files and recompile on change')
  .option('-r --reload', 'Reload the browser on change')
  .option('-c --cat', 'Output injected index file for inspection')
  .description('compile local assets based on Smashfile')
  .action (_target) ->
    target = _target
    compileTasks.push 'compile:serve'  if args.watch
    tasks.start compileTasks

### ---------------- TASKS ---------------------------------------------- ###

# Injects assets into index.jade and compiles
smasher.task 'compile:index', ['compile:assets'], ->
  injectIndex = ->
    logger.verbose "Injecting compiled files into #{chalk.magenta 'index.jade'}"

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
      .pipe $.reload stream:true

  if args.watch
    gulp.task 'inject:index', injectIndex
    gulp.watch "#{dir.client}/index.jade", ['inject:index']

  injectIndex()

# Clear previous compile results and compile all assets
smasher.task 'compile:assets', ['compile:clean'], ->
  logger.info "Compiling assets from #{chalk.green './'+dir.client} to #{chalk.magenta './'+dir.compile}"
  merge.apply @, (
    for r in _.values recipes
      r.watch() if args.watch
      r.compile()
  )

# Compile assets and watch source for changes, recompiling on event
smasher.task 'compile:serve', ->
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
  ), 8000

# Remove previous compilation
smasher.task 'compile:clean', (done) ->
  if fs.existsSync dir.compile
    logger.info "Deleting #{chalk.magenta './'+dir.compile}"
    del [dir.compile], done
  else
    done()
