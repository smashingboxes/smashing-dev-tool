module.exports = (globalConfig) ->

  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers


  ### ---------------- TASKS ---------------------------------------------- ###
  tasks.add 'compile:coffee', ->
    recipe files 'coffee'
      .lint()
      .compile()
      .postProcess()
      .pipe $.if args.verbose, $.using()
      .pipe $.size title:'coffee'
      .pipe dest.compile()


  ### ---------------- RECIPE --------------------------------------------- ###
  recipe = (stream) ->
    stream.lint = ->
      coffeeStylish = require('coffeelint-stylish').reporter
      coffeelintrc = require '../config/lint/coffeelintrc'
      logger.verbose 'linting coffee'
      @
        .pipe $.coffeelint coffeelintrc
        .pipe $.coffeelint.reporter()
        .pipe $.coffeelint.reporter "fail"
      @

    stream.compile = ->
      logger.verbose 'compiling coffee'
      @
        .pipe $.coffee bare:true
      @

    stream.postProcess = ->
      logger.verbose 'post-processing coffee'
      @
        .pipe $.header banner
      @

    stream
