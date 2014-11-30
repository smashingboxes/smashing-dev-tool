# Generates config specific to a local project using liftoff
Liftoff     = require 'liftoff'
argv        = require('minimist')(process.argv.slice 2)
chalk       = require 'chalk'
tildify     = require 'tildify'
_           = require 'lodash'


util        = require '../utils/util'
assumptions = require './assumptions'


{logger, notify, execute} = util

assets = []
config = {}

###
Configure Liftoff
###
liftoff = new Liftoff
  name: 'smash'
  processTitle: 'liftoff'
  moduleName: 'liftoff'
  configName: 'smashfile'
  extensions: require('interpret').jsVariants

liftoff.on 'require', (name) ->
  logger.verbose 'Requiring external module', chalk.magenta(name)

liftoff.on 'requireFail', (name) ->
  logger.verbose 'Failed to load external module', chalk.magenta(name)


# Use Liftoff to find and parse local project config
liftoff.launch
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
      # validType = (a) -> _.isString(a) and _.contains _.keys(assumptions.assets), a
      # projectAssets = _.filter project.assets, validType
      # customAssets = _.filter project.assets, _.isObject
      #
      # for asset in projectAssets
      #   logger.verbose "Adding asset type:", chalk.magenta.bold asset
      #   assets[asset] = assumptions.assets[asset]

      # for asset in customAssets
      #   logger.verbose "Adding custom asset definition:", chalk.red.bold asset.name
      #   logger.verbose asset
      #   assets[asset.ext] = asset


      config =
        assets:       project.assets
        pkg:          pkg
        env:          env
        dir:          _.defaults (project.dir or {}), assumptions.dir
        build:        project.build
        banner:       project.banner
        assumptions:  assumptions

module.exports = config
