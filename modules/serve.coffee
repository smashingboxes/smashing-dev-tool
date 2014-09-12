open = require 'open'
chalk = require 'chalk'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util


  # serve compiled files (dev mode)
  tasks.add 'serve:compiled', ->
    {assets, env, dir, pkg, helpers} = getProject()
    {serverFiles, $} = helpers

    logger.info "Serving #{chalk.red 'compiled'} files with #{chalk.yellow 'project server'} at #{chalk.green 'localhost:4567'}"
    server = require("#{env.configBase}/#{dir.server}")(globalConfig)

    tasks.start 'compile:watch'

    helpers.compiledFiles('*')
      .pipe $.watch()
      .pipe $.livereload()

    server.start()

  # serve built files (production mode)
  tasks.add 'serve:built', ->
    {assets, env, dir, pkg, helpers} = getProject()
    {serverFiles, $} = helpers

    logger.info "Serving #{chalk.red 'built'} files with #{chalk.yellow 'project server'} at #{chalk.green 'localhost:4567'}"
    server = require("#{env.configBase}/#{dir.server}")(globalConfig)

    tasks.start 'compile:watch'
    tasks.start 'build:watch'

    helpers.builtFiles('*')
      .pipe $.watch()
      .pipe $.livereload()

    server.start()


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
