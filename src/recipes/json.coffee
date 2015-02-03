
### ---------------- RECIPE ----------------------------------------------- ###

module.exports =
  name: 'recipe-json'
  attach: ->
    self = @
    @register
      name:   'JSON'
      ext:    'json'
      type:   'data'
      doc:    false
      test:   true
      lint:   true
      reload: true
      compileFn: (stream) ->
        {$, caching} = self.helpers
        {args} = self.util
        stream
          .pipe caching()

          # Lint
          .pipe $.jsonlint()
          .pipe $.jsonlint.reporter()
