coffeeStylish = require('coffeelint-stylish').reporter
coffeelintrc  = require '../config/lint/coffeelintrc'
lazypipe      = require 'lazypipe'

module.exports = (globalConfig) ->
  {args, util, tasks, fileRecipes, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, vendorFiles, compiledFiles,  banner, dest, time, $} = helpers


  fileRecipes.jade = ->
    recipe files '.jade'
      .compile()
      .pipe $.if args.verbose, $.using()
      .pipe $.size title:'jade'
      .pipe dest.compile()
      .pipe $.if args.reload, $.reload stream:true

  ### ---------------- TASKS ---------------------------------------------- ###
  tasks.add 'compile:jade', fileRecipes.jade


  ### ---------------- RECIPE --------------------------------------------- ###
  recipe = (stream) ->
    stream.compile = ->
      @
        .pipe $.jade pretty:true, compileDebug:true
        .on('error', (err) -> logger.error err.message)
      @
    stream
