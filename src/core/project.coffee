###
Project Factory

Mushes together various configurations and
returns a project settings object
###

Liftoff = require 'liftoff'
chalk   = require 'chalk'
tildify = require 'tildify'
_       = require 'lodash'
fs      = require 'fs'
q       = require 'q'

module.exports = (Registry) ->

  # Project Factory constructor
  ProjectFactory = (registry) ->
    self = @
    deferred = q.defer()
    registry.get('util').then (util) ->
      log        = util.logger
      args       = util.args
      currentDir = process.cwd()

      # Configure Liftoff
      liftoff = new Liftoff
        name:         'smash'
        processTitle: 'smasher'
        moduleName:   'smasher'
        configName:   'smashfile'
        extensions:   require('interpret').jsVariants
      liftoff.on 'require', (name, _module) ->
        log.verbose 'Requiring external module', chalk.magenta(name)
        _module.register()  if name is 'coffee-script'  # Auto-register CS modules
      # liftoff.on 'requireFail', (name, err) ->
      #   if args.verbose
      #     log.warn 'Failed to load external module', chalk.magenta(name)

      # Use Liftoff to find and parse local project config
      liftoff.launch {}, (env) ->
        project = _({})
          # Load default smashfile config
          .merge(
            require '../config/_smashfile'
          )

          # Attempt to load a local `smashfile.*`
          .merge(
            if !env.configPath
              log.warn chalk.red 'No SMASHFILE found'  if args.verbose
              {}
            else
              style = chalk.magenta.underline
              log.verbose 'Working in directory', style tildify env.cwd
              log.verbose 'Using Smashfile',      style tildify env.configPath
              process.chdir(env.configBase)
              try require(env.configPath)
              catch error
                log.error 'Could not load project config', error
                {}
          )

          # Mix in environment info
          .merge(
            env: env
          )

          # Gather information from project package.json/bower.json
          .merge(
            pkg:
              bower:
                if fs.existsSync("#{currentDir}/bower.json")
                  try require "#{currentDir}/bower"
                  catch errorBower
                    log.error "Couldn't load bower.json."
                else
                  null
              npm:
                if fs.existsSync("#{currentDir}/package.json")
                  try require "#{currentDir}/package"
                  catch errorNPM
                    log.error "Couldn't load package.json."
                else
                  null
          )

          # Collect paths for easy reference
          .thru(
            (p) -> _.merge p, dir:
              client:  p.client.path
              server:  p.server.path
              vendor:  p.vendor.path
              compile: p.compile.path
              build:   p.build.path
              deploy:  p.deploy.path
              docs:    p.docs.path
              fonts:   p.fonts.path
          )
          .value()

        deferred.resolve project
    deferred.promise

  # Register with Cation DI registry
  Registry.register 'project', ProjectFactory,
    type:      'factory'
    singleton: true
    args:      ['@util']
