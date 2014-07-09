{files, dest, banner, $, lazypipe} = require('../../config/helpers')
{logger, notify, execute} = require('../../config/util')
{assets, tasks, args, dir, pkg} = require('../../config/config')()



cfg =
  imacss: 'images.css'

  imagemin:
    progressive: true



optimizeImages = lazypipe()
  .pipe $.imagemin, cfg.imagemin

encodeImages = lazypipe()
  .pipe $.imacss, cfg.imacss

tasks.add 'build:images', ->
  files('gif', 'jpg', 'png', 'svg')
    .pipe($.using())
    .pipe(optimizeImages())
    # .pipe $.if base64Images, encodeImages()
    .pipe(dest.build())
