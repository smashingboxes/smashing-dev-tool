module.exports = (globalConfig) ->
  {args, util, tasks, recipes, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util
  {assets, env, dir, pkg, helpers} = project = getProject()
  {files,  banner, dest, time, $, logging, watching} = helpers

  ### ---------------- RECIPE ----------------------------------------------- ###
  compile = (stream) ->
    stream
      .pipe $.if args.watch, $.cached 'styl'
      .pipe logging()

      # Compile
      .pipe $.stylus()
      .on('error', (err) -> logger.error err.message)

  ### ---------------- TASKS ---------------------------------------------- ###
  styl =
    compile: ->
      compile files '.styl'
        .pipe dest.compile()
        .pipe $.if args.watch, $.remember 'styl'
        .pipe watching()
