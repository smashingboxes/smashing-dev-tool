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

smasher  = require '../config/global'
helpers = require '../utils/helpers'

# module.exports = ->
{args, util, tasks, recipes, commander, assumptions, rootPath, user, platform, project} = smasher
{logger, notify, execute, merge} = util
{assets, dir, env} = project
{files, dest, $, logging, watching} = helpers

target = null


### ---------------- COMMANDS ------------------------------------------- ###
smasher.command('compile')
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
smasher.task 'compile', ['compile:assets'],  ->
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
      .pipe $.reload stream:true

  if args.watch
    gulp.task 'inject:index', injectIndex
    gulp.watch "#{dir.client}/index.jade", ['inject:index']

  injectIndex()


# Clear previous compile results and compile all assets
smasher.task 'compile:assets', ['compile:clean'], ->
  $.browserSync.notify 'Injecting asset paths into index'

  logger.info "Compiling assets..."  if args.verbose

  # app = merge(
  #   recipes.coffee.compile()
  #   # recipes.js.compile()
  #   # recipes.styl.compile()
  #   # recipes.css.compile()
  #   # recipes.html.compile()
  #   # # recipes.jade.compile()
  #   # recipes.vendor.compile()
  #   # recipes.images.compile()
  #   # recipes.fonts.compile()
  # )

  app = merge.apply @, (r.compile()  for r in _.values recipes)

# Compile assets and watch source for changes, recompiling on event
smasher.task 'compile:serve', ->
  setTimeout (->
    $.browserSync
      server:
        baseDir:          dir.compile
      watchOptions:
        debounceDelay:  100
      logPrefix:      'BrowserSync'
      logConnections: args.verbose
      logFileChanges: args.verbose
      # logLevel:     'debug'
      port:           8080

  ), 5000

# Remove previous compilation
smasher.task 'compile:clean', (done) ->
  if fs.existsSync dir.compile
    logger.info "Deleting #{chalk.magenta './'+dir.compile}"
    del [dir.compile], done
  else
    done()
