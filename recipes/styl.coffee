module.exports = (globalConfig) ->
  {args, util, tasks, fileRecipes, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util
  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, vendorFiles, compiledFiles,  banner, dest, time, $} = helpers


  ### ---------------- TASKS ---------------------------------------------- ###
  fileRecipes.styl = ->
    recipe files '.styl'
      .pipe $.stylus()
      .pipe $.if args.verbose, $.using()
      .pipe $.size title:'styl'
      .pipe dest.compile()
      .pipe $.if args.reload, $.reload stream:true

  tasks.add 'compile:styl', fileRecipes.styl
      # .pipe $.rename extname:'.css'

  ### ---------------- RECIPE ----------------------------------------------- ###
  recipe = (stream) ->
    stream.compile = ->
      @
        .pipe $.stylus()
        .on('error', (err) -> logger.error err.message)
      @
    stream
