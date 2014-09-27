required       = require 'require-dir'
gulp           = require 'gulp'
lazypipe       = require 'lazypipe'
_              = require 'underscore'
merge          = require 'merge-stream'
amdOptimize    = require 'amd-optimize'
bowerRequireJS = require 'bower-requirejs'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util
  {assets, helpers, dir, env} = getProject()
  {vendorFiles, mainFile, compiledFiles, files, dest, $} = helpers

  recipes = {}
  for recipe in ['coffee', 'js', 'styl', 'css', 'jade', 'html', 'json', 'vendor']
    recipes[recipe] = require("../recipes/#{recipe}")(globalConfig)


  ### ---------------- COMMANDS ------------------------------------------- ###
  commander
    .command('compile')
    .alias('c')
    .option('-w, --watch', 'Watch files and recompile on change')
    .description('compile local assets based on Smashfile')
    .action ->
      # if args.watch? or globalConfig.watching?
      #   tasks.start 'compile:watch'
      # else
      #   tasks.start 'compile'
      logger.warn '--- COMPILE TEST ---'


  ### ---------------- TASKS ---------------------------------------------- ###
  tasks.add 'compile', ['compile:clean'], (done)->
    tasks.start ['compile:bower'].concat("compile:#{ext}" for ext, asset of assets), done

  tasks.add 'compile:watch', (done) ->
    args.watch = true
    globalConfig.watching = true

    tasks.start ['compile:bower'].concat("compile:#{ext}" for ext, asset of assets)
    gulp.watch("#{dir.compile}/main.js", ['compile:bower'])



  gulp.task 'compile:require-main', ->
    mainFile()
      .pipe $.coffee()
      .pipe $.using()
      .pipe dest.compile()

  gulp.task 'compile:bower', (done) ->
    bowerRequire =
      config: "#{env.configBase}/#{dir.compile}/main.js"
      transitive: true
    bowerRequireJS bowerRequire, (rjsConfigFromBower) -> done()

  tasks.add 'compile:bower', ['compile:coffee', 'compile:vendor'], (done) ->
    bowerRequire =
      config: "#{env.configBase}/#{dir.compile}/main.js"
      transitive: true
    bowerRequireJS bowerRequire, (rjsConfigFromBower) -> done()



  tasks.add 'compile:clean', ->
    {assets, helpers, dir} = getProject()
    $ = helpers.$

    gulp.src dir.compile
      .pipe $.using()
      .pipe $.rimraf force:true, read:false
