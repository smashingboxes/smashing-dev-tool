fs =              require 'fs'
open =            require 'open'
gulp =            require 'gulp'                  # streaming build system

karma =           require('karma').server

smasher = require '../config/global'
helpers = require '../utils/helpers'
smasher.module
  name:     'test'
  commands: ['test']
  init: (smasher) ->
    {util, tasks, commander, assumptions, smash, user, platform, getProject, rootPath} = smasher
    {logger, notify, execute, args, merge} = util
    {files, $, logging} = helpers


    ### ---------------- COMMANDS ------------------------------------------- ###
    commander
      .command('test')
      .alias('t')
      .option('-w, --watch',     'Watch files and run unit tests on file save')
      .description('Run available tests for source code')
      .action((options) ->
        configPath = "#{rootPath}/src/config/karma.conf.coffee"
        logger.info "Running tests#{if args.watch then ' and watching for changes' else ''}..."

        merge(
          files 'compile', ['.css', '.js']
          files 'test'
        ).pipe $.using()

        # .pipe $.karma
        #   configFile: configPath
        #   action:     if args.watch then 'watch' else 'run'
        # .on 'error', (err) -> throw err

      ).on '--help', ->
        console.log '  Examples:'
        console.log ''
        console.log '    $ smash test --watch'
        console.log ''
