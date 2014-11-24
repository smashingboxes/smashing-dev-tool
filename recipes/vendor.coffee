through2       = require 'through2'
gulp           = require 'gulp'
bowerRequireJS = require 'bower-requirejs'

q = require 'q'

module.exports = (globalConfig) ->
  {args, util, tasks, recipes, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, banner, dest, time, $, logging, watching} = helpers

  # bowerRequire =
  #   config: "#{env.configBase}/#{dir.compile}/main.js"
  #   transitive: true

  ### ---------------- TASKS ---------------------------------------------- ###
  vendor =
    compile: ->
      files 'vendor', '*'
        .pipe logging()
        .pipe gulp.dest "#{dir.compile}/components/vendor"
