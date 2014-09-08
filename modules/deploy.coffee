chalk = require 'chalk'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  commander
    .command('deploy <target>')
    .alias('d')
    .description('Deploy code to a remote target')
    .action (target) ->
      logger.info "Deploying code to #{chalk.yellow target}"
