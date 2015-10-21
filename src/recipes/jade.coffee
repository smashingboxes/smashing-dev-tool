_ = require 'lodash'

coffeeStylish = require('coffeelint-stylish').reporter
coffeelintrc  = require '../config/lint/coffeelintrc'


module.exports =
  name: 'recipe-jade'
  attach: ->
    self = @

    cfg =
      ngHtml2js:
        moduleName: "templates-main-jade"
        prefix: ''
      ngAnnotate:
        remove: true
        add: true
        single_quote: true
      uglify:
        mangle: true
        preserveComments: 'some'

    # building = _.contains args?._, 'build'
    # html2js = (project?.compile?.html2js is true) and building

    ### ---------------- RECIPE --------------------------------------------- ###
    @register
      name:   'Jade'
      ext:    'jade'
      type:   'view'
      doc:    true
      test:   true
      lint:   false
      reload: true
      compileFn: (stream) ->
        {files, dest, $, logging, caching, banner, onError, templateReplace} = self.helpers
        {logger, args} = self.util
        templateReplace stream
        # stream
          .pipe logging()
          .pipe caching()


          # Compile
          # .pipe $.jadeInheritance basedir:'client'
          # .pipe $.filter (file) -> !(/\/_/).test(file.path) || (!/^_/).test(file.relative)  # filter out partials (folders and files starting with "_" )

          .pipe $.jade pretty:true, compileDebug:true, doctype:'html'
          .on('error', onError)

          # Convert to JS for templateCache
          # .pipe $.if html2js, $.htmlmin collapseWhitespace: true
          # .pipe $.if html2js, $.ngHtml2js cfg.ngHtml2js
          # .pipe $.if html2js, $.ngAnnotate cfg.ngAnnotate
          # .pipe $.if html2js, $.concat "#{cfg.ngHtml2js.moduleName}.js"
          # .pipe $.if html2js, $.uglify cfg.uglify
