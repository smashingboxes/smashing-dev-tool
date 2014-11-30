

class Recipe
  constructor: (params={}) ->

    @name      = params.name
    @extension = params.extension
    @type      = params.type or 'data'

    @doc       = params.doc or false
    @test      = params.test or false
    @lint      = params.lint or false
    @reload    = params.reload or false

  compile: (stream) ->
  build: (stream) ->
