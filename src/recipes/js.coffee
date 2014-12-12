smasher   = require '../config/global'
helpers   = require '../utils/helpers'
jsStylish = require 'jshint-stylish'
jshintrc  = require '../config/lint/jshintrc'
_ = require 'lodash'


{util, tasks, commander, assumptions, smash, user, platform, project} = smasher
{logger, notify, execute, args} = util
{files,  banner, dest, time, $, logging, watching, caching, getOutFile} = helpers


cfg =
  ngAnnotate:
    remove: true
    add: true
    single_quote: true
  uglify:
    mangle: true
    preserveComments: 'some'

### ---------------- RECIPE --------------------------------------------- ###
smasher.recipe
  name:   'JavaScript'
  ext:    'js'
  type:   'script'
  doc:    true
  test:   true
  lint:   true
  reload: true
  compileFn: (stream) ->
    stream
      .pipe logging()
      .pipe caching()

      # Lint
      .pipe $.jshint jshintrc
      .pipe $.jshint.reporter jsStylish

      # Post-process
      .pipe $.header banner

  buildFn: (stream) ->
    stream
      .pipe $.angularFilesort()
      .pipe logging()

      # Optimize
      .pipe $.stripDebug()
      .pipe $.ngAnnotate cfg.ngAnnotate
      .pipe $.uglify cfg.uglify

      # Concat
      .pipe $.concat @getOutFile()
