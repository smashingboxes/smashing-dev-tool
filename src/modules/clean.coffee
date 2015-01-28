gulp =      require 'gulp'
_ =         require 'underscore'

module.exports =
  name:     'clean'
  init: (donee) ->
    self = @
    {startTask, commander, assumptions, rootPath, pkg, user, platform, project, util, helpers} = self
    {logger, notify, execute, merge} = util
    {files, $, dest} = helpers


    # Load modules containing task dependencies
    ### ---------------- COMMANDS ------------------------------------------- ###
    @command
      cmd: 'clean'
      description: 'build local assets based on Smashfile'
      action: ->
        toRun = _.pluck _.filter(tasks.tasks, (task, name) -> name.indexOf('clean') >= 0), 'name'
        startTask toRun

    donee()
