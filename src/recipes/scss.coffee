autoprefixer = require('autoprefixer')
pxtorem = require('postcss-pxtorem')
lost = require('lost')

processors = [
  autoprefixer()
  lost()
  pxtorem({prop_white_list: []})
]

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
        {files, dest, $, logging, watching, caching, banner, plumbing, stopPlumbing, onError} = self.helpers
        {logger, notify, execute, merge, args} = self.util
        stream
          .pipe $.sourcemaps.init()
          # .pipe caching 'scss'
          .pipe logging()

          # Lint
          # .pipe $.scssLint()
          .pipe watching()

          # Compile
          .pipe $.sass()
          .pipe $.postcss(processors)
          .on('error', (err) -> logger.error err.message)

          .pipe $.sourcemaps.write './maps'
