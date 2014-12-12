smasher = require '../config/global'
util = require '../utils/util'
helpers = require '../utils/helpers'

coffeeStylish = require('coffeelint-stylish').reporter
coffeelintrc  = require '../config/lint/coffeelintrc'

{tasks, recipes, commander, assumptions, rootPath, user, platform, project} = smasher
{args} = util
{files, $, logging} = helpers

cfg =
  ngHtml2js:
    moduleName: "templates-main"
    prefix: ''


### ---------------- RECIPE --------------------------------------------- ###
smasher.recipe
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
      .pipe $.jade pretty:true, compileDebug:true
      .on('error', (err) -> logger.error err.message)


      # .pipe $.ngHtml2js cfg.ngHtml2js
