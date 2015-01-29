# smasher = require '../config/global'
_ = require 'lodash'

coffeeStylish = require('coffeelint-stylish').reporter
coffeelintrc  = require '../config/lint/coffeelintrc'
#
# {commander, assumptions, rootPath, user, platform, project, helpers, util} = smasher
# {logger, notify, execute, merge, args} = util
# {files, dest, $, logging, watching, caching, banner, plumbing, stopPlumbing, onError} = helpers


module.exports =
  name: 'recipe-jade'
  attach: ->
    self = @
    {args} = self.util
    {files, $, logging, caching, banner} = self.helpers

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

    building = _.contains args?._, 'build'
    html2js = (project?.compile?.html2js is true) and building

    # watching =  args.watch is true
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
        stream
          .pipe $.if args.watch, $.cached 'main'
          .pipe logging()

          # Compile
          # .pipe $.jadeInheritance basedir:'client'
          # .pipe $.filter (file) -> !(/\/_/).test(file.path) || (!/^_/).test(file.relative)  # filter out partials (folders and files starting with "_" )

          .pipe $.jade pretty:true, compileDebug:true
          .on('error', (err) -> logger.error err.message)

          # Convert to JS for templateCache
          # .pipe $.if html2js, $.htmlmin collapseWhitespace: true
          .pipe $.if html2js, $.ngHtml2js cfg.ngHtml2js
          .pipe $.if html2js, $.ngAnnotate cfg.ngAnnotate
          .pipe $.if html2js, $.concat "#{cfg.ngHtml2js.moduleName}.js"
          # .pipe $.if html2js, $.uglify cfg.uglify
