#
# smasher  = require '../config/global'
#
# {commander, assumptions, rootPath, user, platform, project, helpers, util} = smasher
# {logger, notify, execute, merge, args} = util
# {files, dest, $, logging, watching, caching, banner, plumbing, stopPlumbing, onError} = helpers

### ---------------- RECIPE ----------------------------------------------- ###

module.exports =
  name: 'recipe-json'
  attach: ->
    @register
      name:   'JSON'
      ext:    'json'
      type:   'data'
      doc:    false
      test:   true
      lint:   true
      reload: true
      compileFn: (stream) ->
        stream
          .pipe $.if args.watch, $.cached 'main'

          # Lint
          .pipe $.jsonlint()
          .pipe $.jsonlint.reporter()
