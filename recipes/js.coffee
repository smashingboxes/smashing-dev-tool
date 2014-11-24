module.exports = (globalConfig) ->

  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files,  banner, dest, time, $, logging, watching} = helpers

  jsStylish = require 'jshint-stylish'
  jshintrc = require '../config/lint/jshintrc'

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

  ### ---------------- RECIPE --------------------------------------------- ###
  compile = (stream) ->
    stream
      # .pipe $.angularFilesort()
      .pipe $.if args.watch, $.cached 'main'

      # Lint
      .pipe $.jshint jshintrc
      .pipe $.jshint.reporter jsStylish

      # Post-process
      .pipe $.header banner

  build = (stream) ->
    stream
      .pipe $.angularFilesort()

      # Optimize
      .pipe $.stripDebug()
      .pipe $.ngAnnotate cfg.ngAnnotate
      .pipe $.uglify cfg.uglify

      # Concat
      .pipe $.concat 'main.js'


    stream


  ### ---------------- TASKS ---------------------------------------------- ###
  js =
    compile: ->
      compile files '.js'
        .pipe logging()
        .pipe dest.compile()
        # .pipe watching()

    build: ->
      build files 'compile', '.js'
        .pipe logging()
        .pipe dest.build()
        # .pipe watching()
