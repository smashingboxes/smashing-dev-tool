lazypipe = require 'lazypipe'


module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util




  tasks.add 'build:images', ->
    {assets, env, dir, pkg, helpers} = getProject()
    {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers

    cfg =
      imacss: 'images.css'

      imagemin:
        progressive: true


    optimizeImages = lazypipe()
      .pipe $.imagemin, cfg.imagemin

    # encodeImages = lazypipe()
    #   .pipe $.imacss, cfg.imacss


    files('gif', 'jpg', 'png', 'svg')
      .pipe($.using())
      .pipe(optimizeImages())
      # .pipe $.if base64Images, encodeImages()
      .pipe(dest.build())
