htmlhintrc = require '../config/lint/htmlhintrc'

module.exports =
  name: 'recipe-html'
  attach: ->
    self = @
    cfg =
      ngHtml2js:
        moduleName: "templates-main-html"
        prefix: ''
      ngAnnotate:
        remove: false
        add: true
        single_quote: true
      uglify:
        mangle: false
        preserveComments: 'some'

    ### ---------------- RECIPE --------------------------------------------- ###
    @register
      name:   'HTML'
      ext:    'html'
      type:   'view'
      doc:    true
      test:   true
      lint:   true
      reload: true
      compileFn: (stream) ->

        {$, caching, logging, templateReplace} = self.helpers
        {args} = self.util
        templateReplace stream
          .pipe caching()
          .pipe logging()

          # Lint
          .pipe $.htmlhint htmlhintrc
          .pipe $.htmlhint.reporter()


      buildFn: (stream) ->
        {files, $, logging} = self.helpers
        {args, merge} = self.util
        outfile = @getOutFile()

        stream
          .pipe $.htmlmin collapseWhitespace: true
          # .pipe $.ngHtml2js cfg.ngHtml2js
          # .pipe $.concat outfile
          # .pipe $.ngAnnotate cfg.ngAnnotate
