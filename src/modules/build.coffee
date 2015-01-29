gulp    = require 'gulp'
_       = require 'lodash'
del     = require 'del'
chalk   = require 'chalk'
fs      = require 'fs'

module.exports =
  name:     'build'
  init: (donee) ->
    self = @
    {commander, assumptions, rootPath, pkg, user, platform, project, util, helpers} = self
    {logger, notify, execute, merge} = util
    {files, $, dest} = helpers

    target = dir?.build
    buildOpts = null
    buildTasks = ['build:index']

    self.on 'clean', -> self.startTask 'build:clean'

    ### ---------------- COMMANDS ------------------------------------------- ###
    @command
      cmd: 'build [target]'
      alias: 'b'
      description: 'build local assets for production based on Smashfile'
      options: [
        opt: '-c --cat'
        description: 'Output injected index file for inspection'
      ]
      action: (_target) ->
        buildOpts = project.build?[_target] or {}
        target = buildOpts?.out or dir.build
        self.startTask buildTasks


    ### ---------------- TASKS ---------------------------------------------- ###
    @task 'build:assets', ['build:clean', 'compile:assets'], ->
      logger.info "Building assets from #{chalk.magenta './'+project.dir.compile} to #{chalk.red './'+target}"
      logger.verbose 'Building assets...'

      # Ensure needed recipes are loaded and call build(), returning a stream
      merge.apply @, (for a in ['css', 'js', 'html', 'images', 'fonts', 'vendor']
        @loadRecipe(a) unless recipes[a]
        recipes[a].build()
      )

    @task 'build:index', ['build:assets'], ->
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

    @task 'build:serve', ->
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

    @task 'build:clean', (done) ->
      toDelete = _.chain(project.build)
        .pluck 'out'
        .concat [dir.build]
        .filter ((path) -> fs.existsSync path)
        .value()

      if toDelete.length
        logger.info "Deleting #{chalk.magenta ('./'+d for d in toDelete).join(', ')}"
        del toDelete, done
      else done()
    donee()
