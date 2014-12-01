smasher = require '../config/global'
helpers = require '../utils/helpers'
gulp = require 'gulp'

{dir} = project = require '../config/project'
{files, $, dest, logging} = helpers

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

    compile: ->
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

    build: (stream) ->
      if @passThrough
        files(path:@path, (".#{e}" for e in @ext))
          .pipe logging()
          .pipe dest.build()
      else
        @buildFn files(".#{e}" for e in @ext)
          .pipe dest.build()
