
module.exports = (globalConfig) ->

  {args, util, tasks, recipes, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, banner, dest, time, $, logging, watching} = helpers

  coffeeStylish = require('coffeelint-stylish').reporter
  coffeelintrc = require '../config/lint/coffeelintrc'


  ### ---------------- RECIPE --------------------------------------------- ###
  compile = (stream) ->
    stream
      .pipe $.if args.watch, $.cached 'main'
      .pipe logging()

      # Lint
      .pipe $.coffeelint coffeelintrc
      .pipe $.coffeelint.reporter()
      .pipe $.coffeelint.reporter "fail"

      # Compile
      .pipe $.coffee bare:true

      # Post-process
      .pipe $.header banner


  ### ---------------- TASKS ---------------------------------------------- ###
  coffee =
    compile: ->
      compile files '.coffee'
        .pipe dest.compile()
        # .pipe watching()
