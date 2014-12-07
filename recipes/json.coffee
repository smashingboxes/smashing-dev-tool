
smasher  = require '../config/global'
helpers = require '../utils/helpers'

{args, util, tasks, commander, assumptions, smash, user, platform, project} = smasher
{logger, notify, execute} = util
{files, banner, dest, time, $, logging, watching} = helpers


### ---------------- RECIPE ----------------------------------------------- ###
smasher.recipe
  name:   'JSON'
  ext:    'json'
  type:   'data'
  doc:    false
  test:   true
  lint:   true
  reload: true
  compileFn: (stream) ->
    stream
      .pipe $.if args.watch, $.cached 'main'

      # Lint
      .pipe $.jsonlint()
      .pipe $.jsonlint.reporter()
