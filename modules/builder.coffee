gulp =          require 'gulp'
required =      require 'require-dir'
gulp =          require 'gulp'
lazypipe =      require 'lazypipe'
lazy =          require 'lazy.js'
_ =             require 'underscore'

amdOptimize =   require 'amd-optimize'
bowerRequireJS =  require 'bower-requirejs'

cfg =
  ngHtml2js:
    moduleName: "views"
    prefix: ''


module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, compiledFiles, $, dest} = helpers

  build = (mode) ->
    builderTasks = ("#{mode}:#{ext}" for ext, asset of assets)
    console.log builderTasks


  ### ---------------- COMMANDS ------------------------------------------- ###
  commander
    .command('docs')
    .description('Generate documentation based on source code')
    .action ->
      tasks.start 'docs'

  commander
    .command('builder')
    .action ->
      tasks.start 'builder:start'


  ### ---------------- TASKS ---------------------------------------------- ###
  tasks.add 'builder:start', ->

    # TODO: move recipes to globalConfig
    # TODO: recipes.coffee files.coffee()...
    recipes = {}
    for recipe in ['coffee', 'js', 'styl', 'css', 'jade', 'html']
      recipes[recipe] = require("../recipes/#{recipe}")(globalConfig)
    console.log recipes

    bowerRequire =
      config: "#{env.configBase}/#{dir.compile}/main.js"
      transitive: true

    # recipes.js files('js')
    #   .lint()
    #   .compile()
    #   .postProcess()
    #   .pipe dest.compile()

    recipes.coffee files('coffee')
      .lint()
      .compile()
      .postProcess()
      .pipe dest.compile()

    recipes.jade files('jade')
      .compile()
      .pipe $.using()
      .pipe dest.compile()

    recipes.html files('html')
      .lint()
      .optimize()
      .pipe dest.compile()

    # bowerRequireJS bowerRequire, (rjsConfigFromBower) ->
    #   buildConfig = require '../config/build.config'
    #
    #   recipes.js compiledFiles('js')
    #     .concat()
    #     .optimize()
    #     .pipe gulp.dest 'fundip1'
