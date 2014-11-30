gulp = require 'gulp'
smasher  = require '../config/global'
helpers = require '../utils/helpers'

{args, util, tasks, recipes, commander, assumptions, smash, user, platform, project} = smasher
{logger, notify, execute} = util
{assets, env, dir, pkg} = project
{files, banner, dest, time, $, logging, watching} = helpers

cfg =
  imacss: 'images.css'
  imagemin:
    progressive: true

smasher.recipe
  name:   'images'
  ext:    ['png', 'jpg', 'jpeg', 'gif', 'webp', 'svg']
  type:   'data'
  doc:    false
  test:   true
  lint:   false
  reload: true
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
