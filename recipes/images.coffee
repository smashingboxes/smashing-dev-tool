module.exports = (globalConfig) ->

  {args, util, tasks, fileRecipes, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, vendorFiles, compiledFiles,  banner, dest, time, $} = helpers


  cfg =
    imacss: 'images.css'
    imagemin:
      progressive: true

  optimize = ->
    logger.info 'optimizing images'
    @
      .pipe $.imagemin cfg.imagemin
      # .pipe $.imacss cfg.imacss
    @

  ### ---------------- TASKS ---------------------------------------------- ###

  fileRecipes.images = {}
  fileRecipes.images.compile = ->
    files '.png'
      .pipe $.if args.verbose, $.using()
      .pipe $.size title:'images'
      .pipe dest.compile()
      # .pipe $.if args.reload, $.reload stream:true

  fileRecipes.images.build = ->
    files '.png'
      .pipe $.if args.verbose, $.using()
      .pipe $.size title:'images'
      .pipe dest.build()

  tasks.add 'compile:images', fileRecipes.images.compile
  tasks.add 'compile:build', fileRecipes.images.build


  ### ---------------- RECIPE --------------------------------------------- ###
  recipe = (stream) ->
    stream

  recipe
