# smasher  = require '../config/global'
#
# {commander, assumptions, rootPath, user, platform, project, helpers, util} = smasher
# {logger, notify, execute, merge, args} = util
# {files, dest, $, logging, watching, caching, banner, plumbing, stopPlumbing, onError} = helpers


### ---------------- RECIPE ----------------------------------------------- ###
module.exports =
  name: 'recipe-scss'
  attach: ->
    self = @
    @register
      name:   'Sass'
      ext:    'scss'
      type:   'style'
      doc:    false
      test:   false
      lint:   false
      reload: true
      compileFn: (stream) ->
        {$, caching, logging} = self.helpers
        stream
          .pipe $.sourcemaps.init()
          .pipe caching 'scss'
          .pipe logging()

          # Lint
          .pipe $.scssLint()

          # Compile
          .pipe $.sass()
          .on('error', (err) -> logger.error err.message)

          .pipe $.sourcemaps.write './maps'
