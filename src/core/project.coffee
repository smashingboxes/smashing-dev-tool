Liftoff = require 'liftoff'
chalk   = require 'chalk'
tildify = require 'tildify'
_       = require 'lodash'
q       = require 'q'
fs      = require 'fs'


smashfile = require '../config/_smashfile'

module.exports = (Registry) ->

  getProject = (platform, user, util) ->
    self = @
    {logger, args} = util

    # Gather information from package.json/bower.json
    @pkg =
      bower:
        if fs.existsSync("#{process.cwd()}/bower.json")
          try require "#{process.cwd()}/bower"
          catch errorBower
            logger.error "Couldn't load bower.json."
        else
          null

      npm:
        if fs.existsSync("#{process.cwd()}/package.json")
          try require "#{process.cwd()}/package"
          catch errorNPM
            logger.error "Couldn't load package.json."
        else
          null

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
      self.environment = env = environment
      project =
        if !env.configPath
          logger.verbose chalk.red 'No SMASHFILE found'
          {}
        else
          logger.verbose 'Working in directory', chalk.magenta chalk.underline tildify env.cwd
          logger.verbose 'Using Smashfile', chalk.magenta chalk.underline tildify env.configPath
          process.chdir(env.configBase)

          try require(env.configPath)
          catch error
            logger.error 'Could not load project config', error
            null

      _smashfile = _.merge smashfile, project

      _smashfile.dir =
        client:  _smashfile.client.path
        server:  _smashfile.server.path
        vendor:  _smashfile.vendor.path
        compile: _smashfile.compile.path
        build:   _smashfile.build.path
        deploy:  _smashfile.deploy.path
        docs:    _smashfile.docs.path
      _smashfile.env = environment

      _.assign self, _smashfile


  Registry.register 'project', getProject,
    singleton: true
    args: ['@platform', '@user', '@util']
