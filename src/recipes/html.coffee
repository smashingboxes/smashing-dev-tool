smasher  = require '../config/global'
helpers = require '../utils/helpers'
htmlhintrc = require '../config/lint/htmlhintrc'

{tasks, recipes, commander, assumptions, rootPath, user, platform, project, util} = smasher
{logger, notify, execute, merge, args} = util
{files, $, dest} = helpers

cfg =
  ngHtml2js:
    moduleName: "templates-main-html"
    prefix: ''
  ngAnnotate:
    remove: true
    add: true
    single_quote: true
  uglify:
    mangle: true
    preserveComments: 'some'

### ---------------- RECIPE --------------------------------------------- ###
smasher.recipe
  name:   'HTML'
  ext:    'html'
  type:   'view'
  doc:    true
  test:   true
  lint:   true
  reload: true
  compileFn: (stream) ->
    html2js = project.compile.html2js is true
    stream
      .pipe $.if args.watch, $.cached 'main'

      # Lint
      .pipe $.htmlhint htmlhintrc
      .pipe $.htmlhint.reporter()

      # Convert to JS for templateCache
      .pipe $.if html2js, $.htmlmin collapseWhitespace: true
      .pipe $.if html2js, $.ngHtml2js cfg.ngHtml2js
      .pipe $.if html2js, $.ngAnnotate cfg.ngAnnotate
      # .pipe $.if html2js, $.continuousConcat "#{cfg.ngHtml2js.moduleName}.js"
      .pipe $.if html2js, $.concat "#{cfg.ngHtml2js.moduleName}.js"
      # .pipe $.if html2js, $.uglify cfg.uglify


  buildFn: (stream) ->
    stream
      # Optimize
      .pipe $.htmlmin collapseWhitespace: true

      # Concat
      .pipe $.ngHtml2js cfg.ngHtml2js
      .pipe $.ngAnnotate cfg.ngAnnotate
      .pipe $.concat @getOutFile()
      .pipe $.uglify cfg.uglify
