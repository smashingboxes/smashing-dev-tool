chalk = require 'chalk'

smasher = require '../config/global'
smasher.module
  name:     'deploy'
  commands: ['deploy']
  init: (smasher) ->
    {util, tasks, commander, assumptions, smash, user, platform, getProject} = smasher
    {logger, notify, execute, args} = util


    ### ---------------- COMMANDS ------------------------------------------- ###
    commander
      .command('deploy <target>')
      .alias('d')
      .description('Deploy code to a remote target')
      .action (target) ->
        logger.info "Deploying code to #{chalk.yellow target}"
