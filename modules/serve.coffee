open        = require 'open'
chalk       = require 'chalk'
_           = require 'lodash'

smasher = require '../config/global'
project = require '../config/project'
util    = require '../utils/util'
helpers = require '../utils/helpers'

{args, tasks, recipes, commander, assumptions, rootPath, user, platform, project} = smasher
{assets, dir, env} = project
{logger, notify, execute, merge} = util
{files, dest, $, logging, watching} = helpers


### ---------------- COMMANDS ------------------------------------------- ###
smasher.command('serve [target]')
  .alias('s')
  .description('Serve source code to the browser for development purposes')
  .action (target)->
    args.watch = true
    serveTarget = 'compile'
    outDir = dir.compile

    build = []
    # Determine which phase is being watched
    # and what the output directory for those files is
    if _.contains (t for t of build), target
      serveTarget = 'build'
      outDir = build[target].out
    else
      switch target
        when '', 'dev', 'development', 'compiled'
          serveTarget = 'compile'
          outDir = dir.compile
        when 'prod', 'production', 'build'
          serveTarget = 'build'
          outDir = dir.build



    # Start BrowserSync server
    tasks.start serveTarget, "#{serveTarget}:serve"
