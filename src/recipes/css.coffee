csslintrc = require '../config/lint/csslintrc'
_         = require 'lodash'

module.exports =
  name: 'recipe-css'
  attach: ->
    self = @
    cfg =
      csso:                      false # set to true to prevent structural modifications
      css2js:
        splitOnNewline:          true
        trimSpacesBeforeNewline: true
        trimTrailingNewline:     true
      myth:
        sourcemap:               false


    ### ---------------- RECIPE --------------------------------------------- ###
    @register
      name:   'CSS'
      ext:    'css'
      type:   'style'
      doc:    true
      test:   true
      lint:   true
      reload: false
      compileFn: (stream) ->
        {$, files, dest, logging} = self.helpers
        {args} = self.util
        stream
          # Lint
          .pipe $.csslint csslintrc
          .pipe $.csslint.reporter()

          # Post-process
          .pipe $.myth cfg.myth

      buildFn: (stream) ->
        {recipes} = self
        {$, files, dest, logging} = self.helpers
        {args, merge} = self.util
        outfile = recipes.css.getOutFile()

        projectCSS = stream
          .pipe $.csso cfg.csso
          .pipe $.concat 'project.css'

        vendorCSS = files('vendor', '.css', true)
          .pipe $.filter "**/*.css"
          .pipe $.concat 'vendor.css'

        merge([vendorCSS, projectCSS])
          .pipe $.order ['vendor.css', 'project.css']

          .pipe $.concat outfile
          .pipe $.css2js()

          # .pipe $.wrapAmd()
          # .pipe logging()
