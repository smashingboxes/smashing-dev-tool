open = require 'open'
chalk = require 'chalk'
_ = require 'lodash'

browserSync = require 'browser-sync'
reload = browserSync.reload

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
      serveTask = 'compile'
      outDir = dir.compile

      # Determine which phase is being watched
      # and what the output directory for those files is
      if _.contains (t for t of build), target
        serveTask = 'build'
        outDir = build[target].out
      else
        switch target
          when '', 'dev', 'development', 'compiled'
            serveTask = 'compile'
            outDir = dir.compile
          when 'prod', 'production', 'build'
            serveTask = 'build'
            outDir = dir.build

      # Start BrowserSync server
      logger.info "Serving files from #{chalk.magenta './'+outDir} with #{chalk.yellow.bold 'BrowserSync'} at #{chalk.green 'localhost:4567'}"
      browserSync
        server:
          baseDir:"./#{outDir}"

      # Reload server when output dir changes
      tasks.start "#{serveTask}:watch"
      # , ->
      #   files serveTask
      #     .pipe logging()
      #     .pipe watching()


  ### ---------------- TASKS ---------------------------------------------- ###
