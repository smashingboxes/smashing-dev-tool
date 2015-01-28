#
# smasher  = require '../config/global'
#
# {commander, assumptions, rootPath, user, platform, project, helpers, util} = smasher
# {logger, notify, execute, merge, args} = util
# {files, dest, $, logging, watching, caching, banner, plumbing, stopPlumbing, onError} = helpers

### ---------------- RECIPE ----------------------------------------------- ###

module.exports =
  name: 'recipe-styl'
  attach: ->
    @register
      name:   'Stylus'
      ext:    'styl'
      type:   'style'
      doc:    false
      test:   false
      lint:   false
      reload: true
      compileFn: (stream) ->
        stream
          .pipe $.sourcemaps.init()
          .pipe $.if args.watch, $.cached 'styl'
          .pipe logging()

          # Compile
          .pipe $.stylus()
          .on('error', (err) -> logger.error err.message)
          .pipe $.sourcemaps.write './maps'
