lazypipe = require 'lazypipe'


module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, vendorFiles, copyFiles, time, filters, dest, colors, $} = helpers
  {logger, notify, execute} = util

  cfg =
    imacss: 'images.css'

    imagemin:
      progressive: true



  optimizeImages = lazypipe()
    .pipe $.imagemin, cfg.imagemin

  # encodeImages = lazypipe()
  #   .pipe $.imacss, cfg.imacss

  tasks.add 'build:images', ->
    files('gif', 'jpg', 'png', 'svg')
      .pipe($.using())
      .pipe(optimizeImages())
      # .pipe $.if base64Images, encodeImages()
      .pipe(dest.build())
