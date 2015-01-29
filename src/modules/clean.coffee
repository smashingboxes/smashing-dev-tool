gulp =      require 'gulp'
_ =         require 'underscore'

module.exports =
  name:     'clean'
  init: (donee) ->
    self = @
    {commander, assumptions, rootPath, pkg, user, platform, project, util, helpers} = self
    {logger, notify, execute, merge} = self.util
    {files, $, dest} = self.helpers

    # Load modules containing task dependencies
    ### ---------------- COMMANDS ------------------------------------------- ###
    @command
      cmd: 'clean'
      description: 'build local assets based on Smashfile'
      action: ->
        self.emit 'clean'    
        # cleanTasks = _.filter(self._tasks, ((task) -> task.name.indexOf('clean') >= 0))
        # toRun = _.pluck cleanTasks, 'name'
        # self.startTask toRun

    donee()
