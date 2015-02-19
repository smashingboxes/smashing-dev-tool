gulp     = require 'gulp'
chalk    = require 'chalk'
broadway = require 'broadway'
_        = require 'lodash'

module.exports = (Registry) ->
  getRecipes = (project, util, helpers) ->
    self = @
    {assets, dir, env} = project
    {files, dest, $, logging, watching} = helpers
    {args, logger, notify, execute, merge} = util

    gulp.task 'bs-reload', -> $.reload()

    # ------------------ recipes ---------------------
    class Recipe
      constructor: (params={}) ->
        @name        = params.name
        @ext         = if typeof params.ext is 'string' then [params.ext] else params.ext
        @type        = params.type or 'data'
        @doc         = params.doc or false
        @test        = params.test or false
        @lint        = params.lint or false
        @reload      = params.reload or false
        @compileFn   = params.compileFn or (stream) -> stream
        @buildFn     = params.buildFn   or (stream)-> stream
        @passThrough = params.passThrough or false
        @path        = if params.passThrough then (project[@name]?.path or project[@type]?.path or params.path) else params.path

      # Compile this recipe's filetypes into un-optimized, web-ready assets
      compile: =>
        logger.verbose "Compiling #{chalk.magenta @ext} files"
        if @passThrough
          files(path:"#{dir.client}", (".#{e}" for e in @ext))
            .pipe dest.compile()
            .pipe logging()

        else if @type is 'vendor'
          files 'vendor', '*'
            .pipe logging()
            .pipe gulp.dest "#{dir.compile}/components/vendor"

        else
          @compileFn files(".#{e}" for e in @ext)
            .pipe dest.compile()
            .pipe $.if @reload, watching()

      # Build this recipe's compiled assets into optimized, packaged distrobutions
      build: (write=true) =>
        target = dir.build

        logger.verbose "Building #{chalk.magenta @ext} files"
        if @passThrough
          files(path:"#{dir.client}", (".#{e}" for e in @ext))
            .pipe $.if write, (gulp.dest target)
            .pipe logging()

        else if @type is 'vendor'
          files 'vendor', '*'
            .pipe $.if write, (gulp.dest "#{target}/components/vendor")
            .pipe logging()

        else
          @buildFn files 'compile', (".#{e}" for e in @ext)
            .pipe $.if write, (gulp.dest target)
            .pipe logging()

      # Watch this recipe's filetypes and recompile them when they change
      watch: =>
        logger.verbose "Watching #{chalk.magenta @ext} files"
        if @passThrough
          gulp.task "compile:#{@name}", @compile
          gulp.watch "#{dir.client}/#{@path}/**/*{#{".#{e}" for e in @ext}}", if @reload then ["compile:#{@name}"] else ["compile:#{@name}", $.reload]
        else
          gulp.task "compile:#{@ext}", @compile
          gulp.watch "client/**/*.#{@ext}", (if @reload then ["compile:#{@ext}"] else ["compile:#{@ext}", $.reload])

      # Get the name of the built/packaged file to be created for this recipe
      getOutFile: ->
        project.build["#{@type}s"].out or ''

    RecipeManager = new broadway.App()
    RecipeManager.helpers = helpers
    RecipeManager.util = util
    RecipeManager.recipes = []
    RecipeManager.load = (name) ->
      RecipeManager.use require "../recipes/#{name}"
    RecipeManager.register = (recipe={}) ->
      ext = if _.isArray recipe.ext then recipe.name else recipe.ext
      logger.verbose "Registering #{chalk.yellow 'recipe'} for #{chalk.magenta ext}"
      @recipes[ext] = new Recipe recipe

    # Compute relavent recipes based on project and load them
    logger.verbose 'Loading file recipes based on project config...'
    RecipeManager.load(r) for r in project.supportedAssets.concat ['vendor', 'images', 'fonts']

    RecipeManager.init ->
      logger.verbose 'Recipes loaded!'
      self.Recipe  = RecipeManager.Recipe
      _.assign self, RecipeManager.recipes

  Registry.register 'recipes', getRecipes,
    singleton: true
    args: ['@project', '@util', '@helpers']
