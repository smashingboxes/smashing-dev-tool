gulp    = require 'gulp'
_       = require 'lodash'
del     = require 'del'
chalk   = require 'chalk'
fs      = require 'fs'

smasher = require '../config/global'
project = require '../config/project'
util    = require '../utils/util'
helpers = require '../utils/helpers'

smasher.module
  name:     'build'
  commands: ['build']
  dependencies: ['compile']
  init: (smasher) ->
    {tasks, recipes, commander, assumptions, rootPath, user, platform, project} = smasher
    {assets, dir, env} = project
    {logger, notify, execute, merge, args} = util
    {files, dest, $, logging, watching} = helpers

    target = dir.build
    buildOpts = null
    buildTasks = ['build:index']


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

      # Ensure needed recipes are loaded and call build(), returning a stream
      merge.apply @, (for a in ['css', 'js', 'html', 'images', 'fonts', 'vendor']
        smasher.loadRecipe(a) unless recipes[a]
        recipes[a].build()
      )

    smasher.task 'build:index', ['build:assets'], ->
      logger.info "Building index file..."  if args.verbose
      injectIndex = ->
        logger.info "Injecting built files into #{chalk.magenta 'index.jade'}"  if args.verbose

        files path:"#{dir.client}/index.jade"
          .pipe logging()

          # Inject CSS, inject JS
          .pipe $.inject files('build', ['.js'], true).pipe($.angularFilesort()),
            name:'app', ignorePath:'build', addRootSlash:false

          # # Inject vendor files
          # .pipe $.inject files('vendor', '*', false).pipe(dest.build()),
          #   name:'vendor', ignorePath:'build', addRootSlash:false

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
        gulp.task 'inject:index:build', injectIndex
        gulp.watch "#{dir.client}/index.jade", ['inject:index:build']

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
