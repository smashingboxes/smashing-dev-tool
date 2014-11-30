smasher   = require '../config/global'
helpers   = require '../utils/helpers'
jsStylish = require 'jshint-stylish'
jshintrc  = require '../config/lint/jshintrc'


{args, util, tasks, commander, assumptions, smash, user, platform, project} = smasher
{logger, notify, execute} = util
{assets, env, dir, pkg} = project
{files,  banner, dest, time, $, logging, watching} = helpers

cfg =
  ngAnnotate:
    remove: true
    add: true
    single_quote: true
  uglify:
    mangle: true
    preserveComments: 'some'
  bowerRequire:
    config: "#{env.configBase}/#{dir.compile}/main.js"
    transitive: true

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
      # .pipe $.angularFilesort()
      .pipe $.if args.watch, $.cached 'main'

      # Lint
      .pipe $.jshint jshintrc
      .pipe $.jshint.reporter jsStylish

      # Post-process
      .pipe $.header banner

  buildFn: (stream) ->
    stream
      .pipe $.angularFilesort()

      # Optimize
      .pipe $.stripDebug()
      .pipe $.ngAnnotate cfg.ngAnnotate
      .pipe $.uglify cfg.uglify

      # Concat
      .pipe $.concat 'main.js'
