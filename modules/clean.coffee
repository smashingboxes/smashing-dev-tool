gulp =      require 'gulp'
_ =         require 'underscore'


module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  commander
    .command('clean')
    .description('build local assets based on Smashfile')
    .action ->
      toRun = _.pluck _.filter(tasks.tasks, (task, name) -> name.indexOf('clean') >= 0), 'name'

      tasks.start toRun
