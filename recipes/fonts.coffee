smasher  = require '../config/global'
helpers = require '../utils/helpers'

{args, util, tasks, recipes, commander, assumptions, smash, user, platform, project} = smasher
{logger, notify, execute} = util
{files, banner, dest, time, $, logging, watching} = helpers

smasher.recipe
  name:        'fonts'
  ext:         ['eot', 'svg', 'ttf', 'woff']
  type:        'data'
  doc:         false
  test:        true
  lint:        false
  reload:      true
  passThrough: true
  path:        "data/fonts"
