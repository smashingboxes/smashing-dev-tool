open = require 'open'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  commander
    .command('serve')
    .alias('s')
    .description('Serve source code to the browser for development')
    .action ->
      logger.info 'Starting project server...'

      {assets, env, dir, pkg, helpers} = getProject()
      {serverFiles, $} = helpers

      server = require("#{env.configBase}/#{dir.server}")(globalConfig)

      helpers.compiledFiles('*')
        .pipe $.watch()
        .pipe $.livereload()

      server.start()
