open        = require 'open'
chalk       = require 'chalk'
_           = require 'lodash'

module.exports = (Smasher) ->
  {project, util, helpers, project} = Smasher
  {logger, notify, execute, merge, args} = util
  {files, $, dest} = helpers
  {assets, env, dir} = project

  ### ---------------- COMMANDS ------------------------------------------- ###
  Smasher.command
    cmd: 'serve [target]'
    alias: 's'
    description: 'Serve source code to the browser for development purposes'
    action: (target) ->
      args.watch = true
      serveTarget = 'compile'
      outDir = dir.compile

      switch target
        when '', 'dev', 'development', 'compiled'
          serveTarget = 'compile'
          outDir = dir.compile
        when 'prod', 'production', 'build'
          serveTarget = 'build'
          outDir = dir.build

      # Start BrowserSync server
      args.watch = true  if serveTarget is 'compile'
      Smasher.startTask  "#{serveTarget}"
