fs =              require 'fs'
open =            require 'open'
gulp =            require 'gulp'                  # streaming build system

smasher = require '../config/global'
smasher.module
  name:     'test'
  commands: ['test']
  init: (smasher) ->
    {util, tasks, commander, assumptions, smash, user, platform, getProject} = smasher
    {logger, notify, execute, args} = util


    ### ---------------- COMMANDS ------------------------------------------- ###
    commander
      .command('test')
      .alias('t')
      .option('-w, --watch',     'Watch files and run unit tests on file save')
      .description('Run available tests for source code')
      .action((options) ->
        if options.watch
          logger.info 'Watching files and runnign unit tests'
        else
          logger.info 'Running all tests once.'
      ).on '--help', ->
        console.log '  Examples:'
        console.log ''
        console.log '    $ smash test --watch'
        console.log ''
