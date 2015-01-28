
Liftoff = require 'liftoff'
chalk   = require 'chalk'
tildify = require 'tildify'
_       = require 'lodash'
q = require 'q'

module.exports =
  name: 'project'
  attach: ->
    deferred = q.defer()
    @project = deferred.promise
    assumptions = @assumptions
    self = @
    logger = @util.logger

    assets = []
    config = {}
    project = {}
    env = null
    hasPackage = true

    # Gather information from package.json/bower.json
    pkg = try require "#{process.cwd()}/bower"
    catch errorBower
      logger.warn "Couldn't load bower.json."
      try require "#{process.cwd()}/package"
      catch errorNPM
        logger.warn "Couldn't load package.json. Attempting bower.json"

        logger.warn "No package file available. Are you in the right folder?"
        hasPackage = false

        # Return empty package information
        name:    ''
        version: ''

    ### Configure Liftoff ###
    liftoff = new Liftoff
      name: 'smash'
      processTitle: 'smasher'
      moduleName: 'smasher'
      configName: 'smashfile'
      extensions: require('interpret').jsVariants

    liftoff.on 'require', (name) ->
      logger.verbose 'Requiring external module', chalk.magenta(name)

    liftoff.on 'requireFail', (name) ->
      logger.verbose 'Failed to load external module', chalk.magenta(name)

    # Use Liftoff to find and parse local project config
    liftoff.launch {}, (environment) ->
      env = environment
      project = if !env.configPath
        logger.verbose chalk.red 'No SMASHFILE found'
        {}
      else
        logger.verbose 'Working in directory', chalk.magenta chalk.underline tildify env.cwd
        logger.verbose 'Using Smashfile', chalk.magenta chalk.underline tildify env.configPath
        process.chdir(env.configBase)

        try require(env.configPath)
        catch error
          logger.error 'Could not load project config', error


      deferred.resolve self.project =
        assets:       project?.assets or assets
        overrides:    project?.overrides or {}
        pkg:          pkg
        env:          env
        dir:          _.defaults (project?.dir or {}), assumptions?.dir
        build:        project?.build or assumptions?.build
        compile:      project?.compile or assumptions?.compile
        hasPackage:   hasPackage
      # done()
