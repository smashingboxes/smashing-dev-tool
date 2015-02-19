_         = require 'lodash'
jsStylish = require 'jshint-stylish'
jshintrc  = require '../config/lint/jshintrc'

module.exports =
  name: 'recipe-js'
  attach: ->
    self = @

    cfg =
      ngAnnotate:
        remove: true
        add: true
        single_quote: true
      uglify:
        mangle: true
        preserveComments: 'some'

    ### ---------------- RECIPE --------------------------------------------- ###
    @register
      name:   'JavaScript'
      ext:    'js'
      type:   'script'
      doc:    true
      test:   true
      lint:   true
      reload: true
      compileFn: (stream) ->
        {files, dest, $, logging, caching, banner} = self.helpers

        stream
          .pipe logging()
          .pipe caching()

          # Lint
          .pipe $.jshint jshintrc
          .pipe $.jshint.reporter jsStylish

          # Post-process
          .pipe $.header banner

      buildFn: (stream) ->
        {files, dest, $, logging, caching, banner} = self.helpers
        {args, merge} = self.util
        outfile = @getOutFile()
        stream
          .pipe $.stripDebug()
          .pipe $.ngAnnotate cfg.ngAnnotate
          # .pipe $.angularFilesort()

          # .pipe $.concat outfile
          # .pipe $.uglify cfg.uglify
          # .pipe logging()
