
smasher  = require '../config/global'
helpers = require '../utils/helpers'

{util, tasks, recipes, commander, assumptions, smash, user, platform, project} = smasher
{logger, notify, execute, args} = util
{files,  banner, dest, time, $, logging, watching} = helpers


### ---------------- RECIPE ----------------------------------------------- ###
smasher.recipe
  name:   'Sass'
  ext:    'scss'
  type:   'style'
  doc:    false
  test:   false
  lint:   false
  reload: true
  compileFn: (stream) ->
    stream
      .pipe $.sourcemaps.init()
      .pipe $.if args.watch, $.cached 'scss'
      .pipe logging()

      # Lint
      .pipe $.scssLint()

      # Compile
      .pipe $.sass()
      .on('error', (err) -> logger.error err.message)

      .pipe $.sourcemaps.write './maps'
