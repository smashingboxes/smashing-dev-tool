fs =              require 'fs'
open =            require 'open'
gulp =            require 'gulp'                  # streaming build system

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

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
