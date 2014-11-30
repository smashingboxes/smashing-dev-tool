open        = require 'open'
chalk       = require 'chalk'
_           = require 'lodash'
replay      = require 'replay'
browserSync = require 'browser-sync'
reload      = browserSync.reload

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util
  {assets, helpers, dir, env, build} = project = getProject()
  {files, $, logging, watching} = helpers


  ### ---------------- COMMANDS ------------------------------------------- ###
  commander
    .command('serve [target]')
    .alias('s')
    .description('Serve source code to the browser for development purposes')
    .action (target)->
      args.watch = true
      serveTarget = 'compile'
      outDir = dir.compile

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


  ### ---------------- TASKS ---------------------------------------------- ###
