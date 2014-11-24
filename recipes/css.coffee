module.exports = (globalConfig) ->

  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, banner, dest, time, $, logging, watching} = helpers

  csslintrc = require '../config/lint/csslintrc'

  cfg =
    csso:                      false # set to true to prevent structural modifications
    css2js:
      splitOnNewline:          true
      trimSpacesBeforeNewline: true
      trimTrailingNewline:     true
    myth:
      sourcemap:               false


  ### ---------------- RECIPE --------------------------------------------- ###
  compile = (stream) ->
    stream
      # Lint
      # .pipe $.csslint csslintrc
      # .pipe $.csslint.reporter()

      # Post-process
      .pipe $.myth cfg.myth


  build = (stream) ->
    stream
      # Optimize
      .pipe $.csso cfg.csso

      # Concat
      .pipe $.if args.watch, $.continuousConcat 'app-styles.css'
      .pipe $.if !args.watch, $.concat 'app-styles.css'
      .pipe $.css2js()
      .pipe $.wrapAmd()

      # Minify


  ### ---------------- TASKS ---------------------------------------------- ###
  css =
    compile: ->
      compile files '.css'
      .pipe $.if args.watch, $.cached 'css'
      .pipe logging()
      .pipe dest.compile()
      .pipe $.if args.watch, $.remember 'css'
      .pipe watching()


    build: ->
      build files 'compile', '.css'
      .pipe logging()
      .pipe dest.compile()
      .pipe watching()
