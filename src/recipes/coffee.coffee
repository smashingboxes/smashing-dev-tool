
# {commander, assumptions, rootPath, user, platform, project, helpers, util} = smasher
# {logger, notify, execute, merge, args} = util
# {files, dest, $, logging, watching, caching, banner, plumbing, stopPlumbing, onError} = helpers
#


module.exports =
  name: 'recipe-coffee'
  attach: ->
    @register
      name:      'CoffeeScript'
      ext:       'coffee'
      type:      'script'
      doc:       true
      test:      true
      lint:      true
      reload:    true
      compileFn: (stream) ->
        coffeeStylish = require('coffeelint-stylish').reporter
        coffeelintrc = require '../config/lint/coffeelintrc'

        stream
          .pipe caching()
          .pipe logging()

          # Lint
          .pipe $.coffeelint coffeelintrc
          .pipe $.coffeelint.reporter()

          # Compile
          .pipe $.coffee bare:true
          .pipe $.angularFilesort()

          # Post-process
          .pipe $.header banner

#
# ### ---------------- RECIPE --------------------------------------------- ###
# smasher.recipe
#   name:      'CoffeeScript'
#   ext:       'coffee'
#   type:      'script'
#   doc:       true
#   test:      true
#   lint:      true
#   reload:    true
#   compileFn: (stream) ->
#     stream
#       .pipe caching()
#       .pipe logging()
#
#       # Lint
#       .pipe $.coffeelint coffeelintrc
#       .pipe $.coffeelint.reporter()
#
#       # Compile
#       .pipe $.coffee bare:true
#       .pipe $.angularFilesort()
#
#       # Post-process
#       .pipe $.header banner
