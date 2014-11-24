gulp = require 'gulp'

module.exports = (globalConfig) ->

  {args, util, tasks, recipes, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, banner, dest, time, $, logging, watching} = helpers

  fontTypes = ['.eot', '.svg', '.ttf', '.woff']


  ### ---------------- RECIPE --------------------------------------------- ###
  compile = (stream) ->
    stream
      .pipe logging()

  build = (stream) ->
    stream
      .pipe logging()


  ### ---------------- TASKS ---------------------------------------------- ###
  fonts =
    compile: ->
      compile files path:"#{dir.client}/data/fonts", fontTypes
        .pipe gulp.dest "#{dir.compile}/data/fonts"

        
    build: ->
      build files path:"#{dir.client}/data/fonts", fontTypes
        .pipe gulp.dest "#{dir.build}/data/fonts"
