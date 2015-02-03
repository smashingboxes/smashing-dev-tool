gulp    = require 'gulp'
_       = require 'lodash'
del     = require 'del'
chalk   = require 'chalk'
fs      = require 'fs'

module.exports =
  name:     'build'
  init: (donee) ->
    self = @

    {commander, assumptions, recipes, rootPath, pkg, user, platform, project, util, helpers} = self
    {logger, notify, execute, merge, args} = self.util
    {files, $, dest, onError} = self.helpers


    target = self.project.dir?.build
    buildOpts = null
    buildTasks = ['build:index']

    appJSPkg = null

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
        buildOpts = self.project.build?[_target ] or {}
        target = buildOpts?.out or self.project.dir.build
        self.startTask buildTasks


    ### ---------------- TASKS ---------------------------------------------- ###
    @task 'build:assets', ['build:clean', 'compile:assets'], ->
      {recipes, project} = self
      {files, dest, $, watching, logging} = self.helpers
      {logger, args, merge} = self.util
      {dir, pkg} = self.project
      outfile =  self.recipes.js.getOutFile()

      logger.info "Building assets from #{chalk.magenta './'+dir.compile} to #{chalk.red './'+target}"

      transpiled = merge(
        for k in [ 'html', 'css']
          recipes[k].build(false)
            .pipe $.concat "#{k}.js"
      ).pipe($.order ['html.js', 'css.js'])

      merge [
        recipes.js.buildFn(transpiled)
        recipes.images.build(false)
        recipes.fonts.build(false)
      ]
        .pipe gulp.dest target




    @task 'build:index', ['build:assets'], ->
      {recipes} = self
      {files, dest, $, watching, logging} = self.helpers
      {logger, args, merge} = self.util
      {dir} = self.project

      injectIndex = ->
        logger.verbose "Injecting built files into #{chalk.magenta 'index.jade'}"

        appFiles = merge [
          files('build', '.js', true)
          files('build', '.css', false)
        ]

        files path:"#{dir.client}/index.jade"
          .pipe logging()

          .pipe $.inject appFiles,
            name:         'app'
            ignorePath:   'build'
            addRootSlash: false

          # display injected output in console
          .pipe $.if args.cat, $.cat()

          # compile Jade to HTML
          .pipe $.jade compileDebug:true
          .on('error', (err) -> logger.error err.message)

          .pipe $.if args.cat, $.cat()

          # output HTML
          .pipe gulp.dest target
          .pipe logging()
          .pipe watching()

      if args.watch
        gulp.task 'inject:index:build', injectIndex
        gulp.watch "#{dir.client}/index.jade", ['inject:index:build']

      injectIndex()

    @task 'build:serve', ->
      $.browserSync
        server:
          baseDir:       dir.build
        watchOptions:
          debounceDelay:  100
        logPrefix:      'BrowserSync'
        logConnections: args.verbose
        logFileChanges: args.verbose
        # logLevel:     'debug'
        port:           8080

    @task 'build:clean', (done) ->
      {dir} = project = self.project
      toDelete = []
      if fs.existsSync dir.build
        logger.info "Deleting #{chalk.magenta './'+dir.build}"
        del [dir.build], done
      else
        done()
      #
      # toDelete = toDelete.concat [dir.build]
      # console.log toDelete
      # #   .filter ((path) -> fs.existsSync path)
      # #   .value()
      # # console.log toDelete
      #
      # if toDelete.length
      #   logger.info "Deleting #{chalk.magenta ('./'+d for d in toDelete).join(', ')}"
      #   del toDelete, done
      # else done()
    donee()
