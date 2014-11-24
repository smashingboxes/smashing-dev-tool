gulp = require 'gulp'

module.exports = (globalConfig) ->

  {args, util, tasks, recipes, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, banner, dest, time, $, logging, watching} = helpers

  imageTypes = ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg']

  cfg =
    imacss: 'images.css'
    imagemin:
      progressive: true


  ### ---------------- RECIPE --------------------------------------------- ###
  compile = (stream) ->
    stream
      .pipe logging()
      .pipe $.imagemin()

  build = (stream) ->
    stream
      .pipe logging()
      .pipe $.imagemin()



  ### ---------------- TASKS ---------------------------------------------- ###
  images =
    compile: ->
      compile files path:'client/data/images', imageTypes
        .pipe gulp.dest "#{dir.compile}/data/images"
        

    build: ->
      build files path:'client/data/images', imageTypes
        .pipe gulp.dest "#{dir.build}/data/images"
