open = require 'open'
chalk = require 'chalk'

browserSync = require 'browser-sync'
reload = browserSync.reload

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util
  {assets, helpers, dir, env} = getProject()
  {serverFiles, $} = helpers


  ### ---------------- COMMANDS ------------------------------------------- ###
  commander
    .command('serve [target]')
    .alias('s')
    .description('Serve source code to the browser for development')
    .action (target)->
      if typeof target is 'string'
        switch target
          when '', 'dev', 'development', 'compiled'
            tasks.start 'serve:compiled'
          when 'prod', 'production', 'build'
            tasks.start 'serve:built'
          else
            tasks.start 'serve:compiled'
      else
        tasks.start 'serve:compiled'



  ### ---------------- TASKS ---------------------------------------------- ###
  tasks.add 'sync:compiled', ->
    browserSync
      server:
        baseDir: './compile'

    helpers.compiledFiles('*')
      .pipe $.watch()
      .pipe reload stream:true

  tasks.add 'sync:built', ->
    browserSync
      server:
        baseDir: './build'

    helpers.builtFiles('*')
      .pipe $.watch()
      .pipe reload stream:true

  # serve compiled files (dev mode)
  tasks.add 'serve:compiled', ->
    # logger.info "Serving #{chalk.red 'compiled'} files with #{chalk.yellow 'project server'} at #{chalk.green 'localhost:4567'}"
    server = require("#{env.configBase}/#{dir.server}")(globalConfig)

    logger.info "Serving
      #{chalk.red 'compiled'} files
      with #{chalk.yellow 'BrowserSync'}
      at #{chalk.green 'localhost:4567'}"

    globalConfig.watching = true
    tasks.start 'compile:watch'

    # server.start()



  # serve built files (production mode)
  tasks.add 'serve:built', ->
    logger.info "Serving #{chalk.red 'built'} files with #{chalk.yellow 'project server'} at #{chalk.green 'localhost:4567'}"
    server = require("#{env.configBase}/#{dir.server}")(globalConfig)

    tasks.start 'compile:watch'
    tasks.start 'build:watch'

    helpers.builtFiles('*')
      .pipe $.watch()
      .pipe reload stream:true

    server.start()
