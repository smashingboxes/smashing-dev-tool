
module.exports = (globalConfig) ->

  {args, util, tasks, fileRecipes, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, vendorFiles, compiledFiles,  banner, dest, time, $} = helpers


  ### ---------------- TASKS ---------------------------------------------- ###
  fileRecipes.coffee = ->
    coffeeStylish = require('coffeelint-stylish').reporter
    coffeelintrc = require '../config/lint/coffeelintrc'

    recipe files '.coffee'
      .lint()
      .compile()
      .postProcess()
      .pipe $.if args.verbose, $.using()
      .pipe $.size title:'coffee'
      .pipe dest.compile()
      # .pipe $.if args.reload, $.reload stream:true


  tasks.add 'compile:coffee', fileRecipes.coffee


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
