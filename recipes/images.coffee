module.exports = (globalConfig) ->

  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
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

  ### ---------------- RECIPE --------------------------------------------- ###
  recipe = (stream) ->
    stream.optimize = optimize
    stream

  #
  # tasks.add 'compile:images', ->
  #   files ''

  recipe
