gulp =      require 'gulp'
_ =         require 'underscore'
helpers = require '../utils/helpers'


smasher = require '../config/global'
smasher.module
  name:     'clean'
  commands: ['clean']
  dependencies: ['compile', 'build', 'document']
  init: (smasher) ->
    {args, tasks, recipes, commander, assumptions, rootPath, user, platform, project, util} = smasher
    {logger, notify, execute, merge} = util
    {dir, env} = project
    {files, $, dest} = helpers

    # Load modules containing task dependencies
    ### ---------------- COMMANDS ------------------------------------------- ###
    smasher
      .command('clean')
      .description('build local assets based on Smashfile')
      .action ->
        toRun = _.pluck _.filter(tasks.tasks, (task, name) -> name.indexOf('clean') >= 0), 'name'
        tasks.start toRun
