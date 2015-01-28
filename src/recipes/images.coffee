gulp = require 'gulp'
# smasher  = require '../config/global'
#
# {commander, assumptions, rootPath, user, platform, project, helpers, util} = smasher
# {logger, notify, execute, merge, args} = util
# {files, dest, $, logging, watching, caching, banner, plumbing, stopPlumbing, onError} = helpers


module.exports =
  name: 'recipe-images'
  attach: ->
    cfg =
      imacss: 'images.css'
      imagemin:
        progressive: true

    @register
      name:   'images'
      ext:    ['png', 'jpg', 'jpeg', 'gif', 'webp', 'svg']
      type:   'data'
      doc:    false
      test:   true
      lint:   false
      reload: false
      path:  "data/images"
      passThrough: true
  #
  # ### ---------------- RECIPE --------------------------------------------- ###
  # compile = (stream) ->
  #   stream
  #     .pipe logging()
  #     .pipe $.imagemin()
  #
  # build = (stream) ->
  #   stream
  #     .pipe logging()
  #     .pipe $.imagemin()
  #
  #
  #
  # ### ---------------- TASKS ---------------------------------------------- ###
  # images =
  #   compile: ->
  #     compile files path:'client/data/images', imageTypes
  #       .pipe gulp.dest "#{dir.compile}/data/images"
  #
  #
  #   build: ->
  #     build files path:'client/data/images', imageTypes
  #       .pipe gulp.dest "#{dir.build}/data/images"
