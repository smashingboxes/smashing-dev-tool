#
# smasher  = require '../config/global'
#
# {commander, assumptions, rootPath, user, platform, project, helpers, util} = smasher

#  = helpers

### ---------------- RECIPE ----------------------------------------------- ###

module.exports =
  name: 'recipe-styl'
  attach: ->
    self = @
    {files, dest, $, logging, watching, caching, banner, plumbing, stopPlumbing, onError} = self.helpers
    {logger, notify, execute, merge, args} = self.util
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
