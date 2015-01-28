fs =              require 'fs'
open =            require 'open'
gulp =            require 'gulp'                  # streaming build system

module.exports =
  name:     'test'
  init: (donee) ->
    self = @
    {commander, assumptions, rootPath, pkg, user, platform, project, util, helpers} = self
    {logger, notify, execute, merge} = util
    {files, $, dest} = helpers

    ### ---------------- COMMANDS ------------------------------------------- ###
    @command
      cmd: 'test'
      alias: 't'
      option: '-w, --watch',     'Watch files and run unit tests on file save'
      description: 'Run available tests for source code'
      action: (options) ->
        # configPath = "#{rootPath}/src/config/karma.conf.coffee"
        logger.info "Running tests..."

      help: ->
        console.log '  Examples:'
        console.log ''
        console.log '    $ smash test --watch'
        console.log ''

      donee()
