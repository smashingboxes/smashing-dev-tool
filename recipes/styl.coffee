module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util
  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers


  ### ---------------- TASKS ---------------------------------------------- ###
  tasks.add 'compile:styl',  ->
    recipe files('styl')
      .pipe $.if args.verbose and !args.watch, $.using()
      .pipe $.if !args.watch, $.concat('app-styles.styl')
      .pipe $.if args.watch, $.continuousConcat 'app-styles.css'
      .pipe $.stylus error: true
      .on('error', (err) -> logger.error err.message)
      .pipe $.css2js()
      .pipe $.wrapAmd()
      .pipe $.size title:'styl'
      .pipe dest.compile()


  ### ---------------- RECIPE ----------------------------------------------- ###
  recipe = (stream) ->
    stream.compile = ->
      @
        .pipe $.stylus()
        .on('error', (err) -> logger.error err.message)
      @
    stream
