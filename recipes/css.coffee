module.exports = (globalConfig) ->

  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, vendorFiles, compiledFiles,  banner, dest, time, $} = helpers

  cfg =
    csso:                      false # set to true to prevent structural modifications
    css2js:
      splitOnNewline:          true
      trimSpacesBeforeNewline: true
      trimTrailingNewline:     true
    myth:
      sourcemap:               false

  ### ---------------- TASKS ---------------------------------------------- ###
  tasks.add 'compile:css', ->
    recipe files '.css'
      .lint()
      .postProcess()
      .pipe $.if args.verbose, $.using()
      .pipe $.size title:'css'
      .pipe dest.compile()
      .pipe $.if args.reload, $.reload stream:true


  ### ---------------- RECIPE --------------------------------------------- ###
  recipe = (stream) ->
    stream.lint = ->
      csslintrc = require '../config/lint/csslintrc'
      @
        .pipe $.csslint csslintrc
        .pipe $.csslint.reporter()
      @

    stream.postProcess = ->
      @
        .pipe $.myth cfg.myth
      @

    stream.optimize = ->
      @
        .pipe $.csso cfg.csso
      @

    stream.concat = ->
      @
        .pipe $.if args.watch, $.continuousConcat 'app-styles.css'
        .pipe $.if !args.watch, $.concat 'app-styles.css'
        .pipe $.css2js()
        .pipe $.wrapAmd()
      @

    stream
