# Generates config specific to a local project using Smasher
Liftoff =       require 'liftoff'
argv =          require('minimist')(process.argv.slice 2)
chalk =         require 'chalk'
tildify =       require 'tildify'
_ =             require 'underscore'


util = require './util'
assumptions = require './assumptions'
{logger, notify, execute} = util

assets = []
config = {}

###
Configure Liftoff
###


Smasher = new Liftoff
  name: 'smash'
  processTitle: 'smasher'
  moduleName: 'smasher'
  configName: 'smashfile'
  extensions: require('interpret').jsVariants

Smasher.on 'require', (name) ->
  logger.verbose 'Requiring external module', chalk.magenta(name)

Smasher.on 'requireFail', (name) ->
  logger.verbose 'Failed to load external module', chalk.magenta(name)


# Use Liftoff to find and parse local project config
Smasher.launch
  cwd: argv.cwd
  configPath: argv.myappfile
  require: argv.require
  completion: argv.completion
  (env)->
    if !env.configPath
      logger.error chalk.red 'No SMASHFILE found'
      # process.exit 1

    else
      logger.verbose 'Working in directory', chalk.magenta chalk.underline tildify env.cwd
      logger.verbose 'Using Smashfile', chalk.magenta chalk.underline tildify env.configPath

      process.chdir(env.configBase)
      project = require env.configPath
      pkg = require "#{env.configBase}/package"

      # collect asset definitions
      for asset in project.assets
        # load preconfigured assets by name
        if typeof asset is 'string'
          if assumptions.assets[asset]?
            logger.verbose "Adding asset type:", chalk.magenta.bold asset
            assets[asset] = assumptions.assets[asset]
          else
            logger.warn chalk.red "Asset type: \"#{asset}\" not recognized. Please provide a definition."

        # use an asset definition object specified in Smashfile
        else
          logger.verbose "Adding custom asset definition:", chalk.red.bold asset.name
          logger.verbose asset
          assets[asset.ext] = asset

      config =
        assets:       assets
        pkg:          pkg
        env:          env
        dir:          _.defaults (project.dir or {}), assumptions.dir
        assumptions:  assumptions
      config.helpers = require('./helpers')(require('./global'), config)

module.exports = config
