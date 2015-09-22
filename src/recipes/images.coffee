gulp = require 'gulp'

module.exports =
  name: 'recipe-images'
  attach: ->
    self = @
    cfg =
      # imacss: 'images.css'
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
          # .pipe $.imagemin()

      buildFn: (stream) ->
        {$, logging} = self.helpers
        stream
          # .pipe logging()
