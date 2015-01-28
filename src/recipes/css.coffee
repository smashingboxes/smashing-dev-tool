smasher  = require '../config/global'
csslintrc = require '../config/lint/csslintrc'
_ = require 'lodash'

#
# {commander, assumptions, rootPath, user, platform, project, helpers, util} = smasher
# {logger, notify, execute, merge, args} = util
# {files, dest, $, logging, watching, caching, banner, plumbing, stopPlumbing, onError} = helpers

module.exports =

  name: 'recipe-css'

  attach: ->
    cfg =
      csso:                      false # set to true to prevent structural modifications
      css2js:
        splitOnNewline:          true
        trimSpacesBeforeNewline: true
        trimTrailingNewline:     true
      myth:
        sourcemap:               false


    ### ---------------- RECIPE --------------------------------------------- ###
    @register
      name:   'CSS'
      ext:    'css'
      type:   'style'
      doc:    true
      test:   true
      lint:   true
      reload: false
      compileFn: (stream) ->
        stream
          # Lint
          .pipe $.csslint csslintrc
          .pipe $.csslint.reporter()

          # Post-process
          .pipe $.myth cfg.myth

      buildFn: (stream) ->
        stream
          # Optimize
          .pipe $.csso cfg.csso

          # Concat
          .pipe $.if (args.watch and _.contains args, 'build'), $.continuousConcat @getOutFile()
          .pipe $.if !args.watch, $.concat @getOutFile()
          # .pipe $.css2js()
          # .pipe $.wrapAmd()

        # Minify

### ---------------- TASKS ---------------------------------------------- ###
# css =
#   compile: ->
#     compile files '.css'
#     .pipe $.if args.watch, $.cached 'css'
#     .pipe logging()
#     .pipe dest.compile()
#     .pipe $.if args.watch, $.remember 'css'
#     .pipe watching()
#
#
#   build: ->
#     build files 'compile', '.css'
#     .pipe logging()
#     .pipe dest.compile()
#     .pipe watching()
