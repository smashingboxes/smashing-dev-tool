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
    {logger, notify, execute, merge, args} = self.util
    {files, $, dest, onError} = self.helpers

    target        = self.project.dir?.build
    buildOpts     = null
    buildTasks    = null
    includeVendor = null
    includeIndex  = null

    cfg =
      ngAnnotate:
        remove: true
        add: true
        single_quote: true
      uglify:
        mangle: true
        preserveComments: 'some'

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
        project = self.project
        buildOpts = project.build or {}

        target        = buildOpts.out or project.dir.build
        includeVendor = if buildOpts.vendor? then buildOpts.vendor else true
        includeIndex  = if buildOpts.index? then buildOpts.index else true

        buildTasks = if includeIndex then ['build:index']
        else ['build:assets']

        self.startTask buildTasks



    ### ---------------- TASKS ---------------------------------------------- ###

    # Build assets and start server
    @task 'build', ['build:index'], (done) ->
      self.startTask 'build:serve'

    # Build assets from compiled source
    @task 'build:assets', ['build:clean', 'compile:assets'], ->
      {recipes, project}                           = self
      {files, dest, $, watching, logging, onError} = self.helpers
      {logger, args, merge}                        = self.util
      {dir, pkg}                                   = self.project

      outfile = self.recipes.js.getOutFile()
      target ?= 'build'

      logger.info "Building assets from #{chalk.magenta './'+dir.compile} to #{chalk.red './'+target}"


      # app assets
      _m1 = [
        recipes['html'].build(false)
        recipes['css'].build(false)
        recipes['js'].build(false)
      ]
      _m1.push files('vendor', '.js')  if includeVendor

      m1 = merge _m1
        .pipe $.order [
          '**/jquery.js'
          '**/*jquery*.*'
          '**/angular.js'
          '**/*angular*.*'
          'components/vendor/**/*'
          'app.js'
        ]
        .pipe $.concat outfile
        .pipe $.uglify cfg.uglify
        .pipe $.if args.cat, $.cat()


      # app data
      m2 = merge [
        recipes.images.build()
        recipes.fonts.build()
      ]

      merge [m1, m2]
        .pipe $.plumber()
        .pipe gulp.dest target


    @task 'build:index', ['build:assets'], ->
      {recipes} = self
      {files, dest, $, watching, logging, onError} = self.helpers
      {logger, args, merge} = self.util
      {dir} = self.project

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

        .pipe $.if args.cat, $.cat()

        .pipe $.jade compileDebug:true
        .on('error', (err) -> logger.error err.message)

        .pipe gulp.dest target
        .pipe logging()


    @task 'build:serve', ->
      $.browserSync
        server:
          baseDir:       target
        watchOptions:
          debounceDelay:  100
        logPrefix:      'BrowserSync'
        logConnections: args.verbose
        logFileChanges: args.verbose
        # logLevel:     'debug'
        port:           8080


    @task 'build:clean', (done) ->
      {dir, build} = project = self.project
      toDelete = []
      if fs.existsSync dir.build
        logger.info "Deleting #{chalk.magenta './'+dir.build}"
        del [dir.build], done
      else if fs.existsSync build.out
        logger.info "Deleting #{chalk.magenta './'+build.out}"
        del [build.out], done
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
