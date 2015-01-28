_         = require 'lodash'
# smasher   = require '../config/global'
jsStylish = require 'jshint-stylish'
jshintrc  = require '../config/lint/jshintrc'

#
# {commander, assumptions, rootPath, user, platform, project, helpers, util} = smasher
# {logger, notify, execute, merge, args} = util
# {files, dest, $, logging, watching, caching, banner, plumbing, stopPlumbing, onError} = helpers

module.exports =
  name: 'recipe-js'
  attach: ->
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
        stream
          .pipe $.angularFilesort()
          .pipe logging()
          .pipe caching()

          # Lint
          .pipe $.jshint jshintrc
          .pipe $.jshint.reporter jsStylish

          # Post-process
          .pipe $.header banner

      buildFn: (stream) ->
        stream
          .pipe $.angularFilesort()
          .pipe logging()

          # Optimize
          .pipe $.stripDebug()
          .pipe $.ngAnnotate cfg.ngAnnotate
          .pipe $.uglify cfg.uglify

          # Concat
          .pipe $.concat @getOutFile()
