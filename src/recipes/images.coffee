gulp = require 'gulp'
# smasher  = require '../config/global'
#
# {commander, assumptions, rootPath, user, platform, project, helpers, util} = smasher
# {logger, notify, execute, merge, args} = util
# {files, dest, $, logging, watching, caching, banner, plumbing, stopPlumbing, onError} = helpers


module.exports =
  name: 'recipe-images'
  attach: ->
    self = @
    cfg =
      imacss: 'images.css'
      imagemin:
        progressive: true

    @register
      name:   'images'
      ext:    ['png', 'jpg', 'jpeg', 'gif', 'webp', 'svg']
      type:   'data'
      doc:    false
      test:   true
      lint:   false
      reload: false
      compileFn: (stream) ->
        {$, logging} = self.helpers
        stream
          .pipe logging()
          .pipe $.imagemin()

      buildFn: (stream) ->
        {$, logging} = self.helpers
        stream
          .pipe logging()
