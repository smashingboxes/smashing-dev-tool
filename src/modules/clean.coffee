gulp =      require 'gulp'
_ =         require 'underscore'

module.exports = (Smasher) ->
  {commander, assumptions, rootPath, pkg, user, platform, project, util, helpers} = Smasher
  {logger, notify, execute, merge} = util
  {files, $, dest} = helpers

  # Load modules containing task dependencies
  ### ---------------- COMMANDS ------------------------------------------- ###
  Smasher.command
    cmd: 'clean'
    description: 'build local assets based on Smashfile'
    action: ->
      Smasher.emit 'clean'
      # cleanTasks = _.filter(self._tasks, ((task) -> task.name.indexOf('clean') >= 0))
      # toRun = _.pluck cleanTasks, 'name'
      # self.startTask toRun
