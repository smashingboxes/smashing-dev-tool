module.exports = (globalConfig) ->

  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, vendorFiles, compiledFiles,  banner, dest, time, $} = helpers

  cfg =
    ngAnnotate:
      remove: true
      add: true
      single_quote: true
    uglify:
      mangle: true
      preserveComments: 'some'
    bowerRequire:
      config: "#{env.configBase}/#{dir.compile}/main.js"
      transitive: true



  ### ---------------- TASKS ---------------------------------------------- ###
  tasks.add 'compile:js', ->
    recipe files '.js'
      .lint()
      .compile()
      .postProcess()
      .pipe $.if args.verbose, $.using()
      .pipe $.size title:'js'
      .pipe dest.compile()
      .pipe $.if args.reload, $.reload stream:true


  tasks.add 'build:js', ->
    bowerRequireJS cfg.bowerRequire, (rjsConfigFromBower) ->
      buildConfig = require '../../config/build.config'
      recipe files 'compile', '.js'
        .pipe $.requirejs buildConfig
        .concat()
        .optimize()
        .pipe $.if args.verbose, $.using()
        .pipe $.size title:'js'
        .pipe dest.build()



  ### ---------------- RECIPE --------------------------------------------- ###
  recipe = (stream) ->
    stream.lint = ->
      logger.verbose 'linting js'
      jsStylish = require 'jshint-stylish'
      jshintrc = require '../config/lint/jshintrc'
      @
        .pipe $.jshint jshintrc
        .pipe $.jshint.reporter jsStylish
      @

    stream.compile = ->
      logger.verbose 'compiling js'
      @

    stream.postProcess = ->
      logger.verbose 'post-processing js'
      @
        .pipe $.header banner
      @

    stream.concat = ->
      logger.verbose 'concat js'
      buildConfig = require '../config/build.config'
      @
        .pipe $.requirejs buildConfig
        .pipe $.concat 'main.js'
      @

    stream.optimize = ->
      logger.verbose 'optimizing js'
      @
        .pipe $.stripDebug()
        .pipe $.ngAnnotate cfg.ngAnnotate
        .pipe $.uglify cfg.uglify
      @

    stream
