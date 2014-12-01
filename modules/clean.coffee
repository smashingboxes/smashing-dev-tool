gulp =      require 'gulp'
_ =         require 'underscore'
smasher  = require '../config/global'
helpers = require '../utils/helpers'

{args, tasks, recipes, commander, assumptions, rootPath, user, platform, project, util} = smasher
{logger, notify, execute, merge} = util
{dir, env} = project
{files, $, dest} = helpers


### ---------------- COMMANDS ------------------------------------------- ###
commander
  .command('clean')
  .description('build local assets based on Smashfile')
  .action ->
    toRun = _.pluck _.filter(tasks.tasks, (task, name) -> name.indexOf('clean') >= 0), 'name'

    tasks.start toRun
