gulp    = require 'gulp'
_       = require 'lodash'
del     = require 'del'
chalk   = require 'chalk'
fs      = require 'fs'
open    = require 'open'

module.exports =
  name:     'document'
  init: (donee) ->
    self = @
    {commander, assumptions, rootPath, pkg, user, platform, util, helpers} = self
    {args, logger, notify, execute, merge} = self.util
    {files, dest, $, logging, watching} = self.helpers

    self.on 'clean', -> self.startTask 'docs:clean'

    @project.then (project) ->
      # console.log project
      {assets, dir, env} = project

      ### ---------------- COMMANDS ------------------------------------------- ###
      self.command
        cmd: 'docs'
        description: 'Generate documentation based on source code'
        action: ->
          self.startTask 'docs'

      ### ---------------- TASKS ---------------------------------------------- ###
      self.task 'docs', (done) ->
        # notify "Groc", "Generating documentation..."
        logger.info "Generating documentation in #{chalk.magenta './'+dir.docs}"

        docsGlob = ["README.md"]

        for asset in assets
          docsGlob.push "#{dir.client}/**/*.#{asset}"
          docsGlob.push "#{dir.server}/**/*.#{asset}"

        grocjson = JSON.stringify {
          'glob': docsGlob
          'except': [
            "#{dir.client}/components/vendor/**/*"
          ]
          'github':           false
          'out':              dir.docs
          'repository-url':   self.pkg.repository?.url or ''
          'silent':           !args.verbose?
        }, null, 2

        # Dynamically generate .groc.json from config
        fs.writeFile "#{env.configBase}/.groc.json", grocjson, 'utf8', ->
          logger.info "Generated dynamic #{chalk.green '.groc.json'} from project config"  if args.verbose

          # Use our copy of Groc to generate documentation for the project
          require("#{self.rootPath}/node_modules/groc").CLI [], (error)->
            process.exit(1) if error
            # notify "Groc", "Success!"
            open "#{dir.docs}/index.html"
            done()

      self.task 'docs:clean', (done) ->
        {dir} = self.project
        if fs.existsSync dir.docs
          logger.info "Deleting #{chalk.magenta './'+dir.docs}"
          del [dir.docs], done
        else
          done()

      donee()
