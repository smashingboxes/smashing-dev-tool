open        = require 'open'
chalk       = require 'chalk'
_           = require 'lodash'

module.exports =
  name:     'serve'
  init: (donee) ->
    self = @
    {project, util, helpers, project} = self
    {logger, notify, execute, merge, args} = self.util
    {files, $, dest} = self.helpers
    {assets, env, dir} = self.project

    ### ---------------- COMMANDS ------------------------------------------- ###
    @command
      cmd: 'serve [target]'
      alias: 's'
      description: 'Serve source code to the browser for development purposes'
      action: (target) ->
        {dir} = self.project
        args.watch = true
        serveTarget = 'compile'
        outDir = dir.compile

        build = []
        # Determine which phase is being watched
        # and what the output directory for those files is
        if _.contains (t for t of build), target
          serveTarget = 'build'
          outDir = build[target].out
        else
          switch target
            when '', 'dev', 'development', 'compiled'
              serveTarget = 'compile'
              outDir = dir.compile
            when 'prod', 'production', 'build'
              serveTarget = 'build'
              outDir = dir.build


        # Start BrowserSync server
        args.watch = true  if serveTarget is 'compile'
        self.startTask  "#{serveTarget}"


    donee()
