module.exports = (globalConfig) ->

  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, banner, dest, time, $, logging, watching} = helpers


  ### ---------------- RECIPE ----------------------------------------------- ###
  compile = (stream) ->
    stream
      .pipe $.if args.watch, $.cached 'main'
      
      # Lint
      .pipe $.jsonlint()
      .pipe $.jsonlint.reporter()


  ### ---------------- TASKS ---------------------------------------------- ###
  json =
    compile: ->
      compile files '.json'
        .pipe logging()
        .pipe dest.compile()
        # .pipe watching()
