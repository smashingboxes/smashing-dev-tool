gulp    = require 'gulp'
_       = require 'lodash'
del     = require 'del'
chalk   = require 'chalk'
fs      = require 'fs'
q = require 'q'

module.exports =
  name: 'compile'
  init: (donee) ->
    self = @
    {recipes, commander, recipes, assumptions, rootPath, pkg, project, util, helpers} = self
    {logger, notify, execute, merge, args} = self.util
    {files, $, dest, logging} = self.helpers
    {dir} = self.project

    target = null
    compileTasks = ['compile:assets', 'compile:index']

    self.on 'clean', -> self.startTask 'compile:clean'

    # ### ---------------- COMMANDS ------------------------------------------- ###
    @command
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
        self.startTask compileTasks


    # ### ---------------- TASKS ---------------------------------------------- ###

    # Compile assets and start server
    @task 'compile', ['compile:index'], (done) ->
      self.startTask 'compile:serve'

    # Injects assets into index.jade and compiles
    @task 'compile:index', ['compile:assets'], ->
      dir = self.project.dir
      {files, $, dest, logging} = self.helpers
      {merge, args, logger} = self.util

      injectIndex = ->
        logger.info "Injecting compiled files into #{chalk.magenta 'index.jade'}"

        appFiles = merge [
          files('compile', '.js', true).pipe($.angularFilesort())
          files('compile', '.css', false)
        ]
          .pipe $.order [
            '**/jquery.js'
            '**/*jquery*.*'
            '**/angular.js'
            '**/*angular*.*'
            'components/vendor/**/*'
            'app.js'
          ]
        .pipe $.plumber()

        files path:"#{dir.client}/index.jade"
          .pipe logging()

          .pipe $.inject appFiles,
            name:         'app'
            ignorePath:   'compile'
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
    @task 'compile:assets', ['compile:clean'], ->
      {recipes} = self
      {dir, assets} = self.project
      {merge, args} = self.util
      {files, $, dest} = self.helpers
      supportedAssets = self.assumptions.supportedAssets

      logger.info "Compiling assets from #{chalk.green './'+dir.client} to #{chalk.magenta './'+dir.compile}"

      toCompile = _
        .chain supportedAssets
        .intersection assets
        .concat 'images', 'vendor' #, 'fonts'
        .value()

      ax = for asset in toCompile
        recipes[asset].watch() if args.watch
        recipes[asset].compile()

      merge ax

    # Compile assets and watch source for changes, recompiling on event
    @task 'compile:serve', ->
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

    # Remove previous compilation
    @task 'compile:clean', (done) ->
      {dir} = self.project
      if fs.existsSync dir.compile
        logger.info "Deleting #{chalk.magenta './'+dir.compile}"
        del [dir.compile], done
      else
        done()

    donee()
