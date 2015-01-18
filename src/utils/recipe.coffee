gulp    = require 'gulp'
chalk   = require 'chalk'

helpers = require '../utils/helpers'
util    = require '../utils/util'
project = require '../config/project'

assumptions = require '../config/assumptions'
{dir, overrides} = project
{files, $, dest, logging, watching} = helpers
{args, logger} = util

module.exports =
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
      @passThrough = params.passThrough
      @path        = if params.passThrough then (overrides?.assets?[@name]?.path or params.path) else params.path
      console.log @path


    # Compile this recipe's filetypes into un-optimized, web-ready assets
    compile: =>
      logger.verbose "Compiling #{chalk.magenta @ext} files"
      if @passThrough
        files(path:"#{dir.client}/#{@path}", (".#{e}" for e in @ext))
          .pipe logging()
          .pipe gulp.dest "#{dir.compile}/#{@path}"
      else if @type is 'vendor'
        files 'vendor', '*'
          .pipe logging()
          .pipe gulp.dest "#{dir.compile}/components/vendor"
      else
        @compileFn files(".#{e}" for e in @ext)
          .pipe dest.compile()
          .pipe $.if @reload, watching()

    # Build this recipe's compiled assets into optimized, packaged distrobutions
    build: =>
      # Compute specific build target
      buildOpts = project.build?[args._[1]]
      target = buildOpts?.out or dir.build

      logger.verbose "Building #{chalk.magenta @ext} files"
      if @passThrough
        files(path:"#{dir.compile}/#{@path}", (".#{e}" for e in @ext))
          .pipe logging()
          .pipe gulp.dest "#{target}/#{@path}"
      else
        @buildFn files 'compile', (".#{e}" for e in @ext)
          .pipe logging()
          .pipe gulp.dest target

    # Watch this recipe's filetypes and recompile them when they change
    watch: =>
      logger.verbose "Watching #{chalk.magenta @ext} files"

      if @passThrough
        gulp.task "compile:#{@name}", @compile
        gulp.watch "#{dir.client}/#{@path}/**/*{#{".#{e}" for e in @ext}}", if @reload then ["compile:#{@name}"] else ["compile:#{@name}", $.reload]
      else
        gulp.task "compile:#{@ext}", @compile
        gulp.watch "client/**/*.#{@ext}", if @reload then ["compile:#{@ext}"] else ["compile:#{@ext}", $.reload]


    # Get the name of the built/packaged file to be created for this recipe
    getOutFile: ->
      buildOpts = project.build?[args._[1]]
      if buildOpts
        buildOpts["#{@type}s"] or assumptions.build["#{@type}s"]
      else
        assumptions.build["#{@type}s"]
