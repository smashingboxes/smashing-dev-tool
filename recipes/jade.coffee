coffeeStylish = require('coffeelint-stylish').reporter
coffeelintrc  = require '../config/lint/coffeelintrc'
lazypipe      = require 'lazypipe'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers


  ### ---------------- TASKS ---------------------------------------------- ###
  tasks.add 'compile:jade', ->
    recipe files 'jade'
      .compile()
      .pipe $.if args.verbose, $.using()
      .pipe $.size title:'jade'
      .pipe dest.compile()

  ### ---------------- RECIPE --------------------------------------------- ###
  recipe = (stream) ->
    stream.compile = ->
      logger.verbose 'compiling jade'
      @
        .pipe $.jade()
      @
    stream
