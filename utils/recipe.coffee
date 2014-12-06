gulp    = require 'gulp'
chalk   = require 'chalk'
argv    = require('minimist')(process.argv.slice 2)

helpers = require '../utils/helpers'
util    = require '../utils/util'
project = require '../config/project'


{dir, assumptions} = project
{files, $, dest, logging, watching} = helpers
{logger} = util

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
      @path        = params.path


    compile: =>
      logger.info "Compiling #{chalk.magenta @ext} files"  if argv.verbose
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

    build: =>
      # Specific build target
      buildOpts = project.build?[argv._[1]]
      target = buildOpts?.out or dir.build

      logger.info "Building #{chalk.magenta @ext} files"  if argv.verbose
      if @passThrough
        files(path:"#{dir.compile}/#{@path}", (".#{e}" for e in @ext))
          .pipe logging()
          .pipe gulp.dest "#{target}/#{@path}"
      else
        @buildFn files 'compile', (".#{e}" for e in @ext)
          .pipe logging()
          .pipe gulp.dest target

    watch: =>
      logger.info "Watching #{chalk.magenta @ext} files"
      gulp.task "compile:#{@ext}", @compile
      gulp.watch "client/**/*.#{@ext}", if @reload then ["compile:#{@ext}"] else ["compile:#{@ext}", $.reload]

    # Get the name of the concat'd file to be created for a given asset type
    getOutFile: ->
      buildOpts = project.build?[argv._[1]]
      if buildOpts
        buildOpts["#{@type}s"] or assumptions.build["#{@type}s"]
      else
        assumptions.build["#{@type}s"]
