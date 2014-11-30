smasher  = require '../config/global'
helpers = require '../utils/helpers'
htmlhintrc = require '../config/lint/htmlhintrc'

{args, tasks, recipes, commander, assumptions, rootPath, user, platform, project, util} = smasher
{logger, notify, execute, merge} = util
{dir, env} = project
{files, $, dest} = helpers


cfg =
  ngHtml2js:
    moduleName: "templates-main"
    prefix: ''

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
    stream
      .pipe $.if args.watch, $.cached 'main'

      # Lint
      .pipe $.htmlhint htmlhintrc
      .pipe $.htmlhint.reporter()

      # Convert to JS for templateCache
      .pipe $.ngHtml2js cfg.ngHtml2js

  buildFn: (stream) ->
    stream
      # Optimize
      .pipe $.htmlmin collapseWhitespace: true

      # Concat
      .pipe $.ngHtml2js cfg.ngHtml2js
      .pipe $.concat 'app-views.js'
