gulp    = require 'gulp'
_       = require 'lodash'
del     = require 'del'
chalk   = require 'chalk'
fs      = require 'fs'

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

    self.on 'clean', ->self.startTask 'compile:clean'

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

    # Injects assets into index.jade and compiles
    @task 'compile', ['compile:index'], (done) ->
      self.startTask 'compile:serve'
    @task 'compile:index', ['compile:assets'], ->
      console.log 'compile index!'
      dir = self.project.dir
      {files, $, dest, logging} = self.helpers

      injectIndex = ->

        logger.verbose "Injecting compiled files into #{chalk.magenta 'index.jade'}"

        files path:"#{dir.client}/index.jade"
          .pipe logging()
          # Inject CSS, inject JS
          .pipe $.inject files('compile', ['.css', '.js'], false),
            name:         'app'
            ignorePath:   'compile'
            addRootSlash: false

          # Inject vendor files
          .pipe $.inject files('vendor', '*', false),
            name:         'vendor'
            ignorePath:   'client'
            addRootSlash: false

          # Display injected output in console
          .pipe $.if args.cat, $.cat()

          # Compile Jade to HTML
          .pipe $.jade pretty:true, compileDebug:true
          .on('error', (err) -> logger.error err.message)

          # Output HTML
          .pipe dest.compile()
          .pipe $.reload stream:true
        # console.log 'injecting..........................'
      if args.watch
        gulp.task 'inject:index:compile', injectIndex
        gulp.watch "#{dir.client}/index.jade", ['inject:index:compile']

      injectIndex()

    # Clear previous compile results and compile all assets
    @task 'compile:assets', ['compile:clean'], ->
      {dir} = self.project
      logger.info "Compiling assets from #{chalk.green './'+dir.client} to #{chalk.magenta './'+dir.compile}"
      merge.apply @, (
        for r in _.values self.recipes
          r.watch?() if args.watch
          r.compile?()
      )

    # Compile assets and watch source for changes, recompiling on event
    @task 'compile:serve', ->
      setTimeout (->
        $.browserSync
          server:
            baseDir:          dir.compile
          watchOptions:
            debounceDelay:  100
          logPrefix:      'BrowserSync'
          # logConnections: true
          logFileChanges: true
          # logLevel:     'debug'
          port:           8080
      ), 1000

    # Remove previous compilation
    @task 'compile:clean', (done) ->
      {dir} = self.project
      if fs.existsSync dir.compile
        logger.info "Deleting #{chalk.magenta './'+dir.compile}"
        del [dir.compile], done
      else
        done()

    donee()
