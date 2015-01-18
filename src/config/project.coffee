# Generates config specific to a local project using liftoff
Liftoff     = require 'liftoff'
argv        = require('minimist')(process.argv.slice 2)
chalk       = require 'chalk'
tildify     = require 'tildify'
_           = require 'lodash'

assumptions = require './assumptions'
util        = require '../utils/util'
{logger, notify, execute} = util

assets = []
config = {}
project = null
env = null

# Gather information from package.json/bower.json
pkg = try require "#{env.configBase}/package"
catch error
  logger.verbose "Couldn't load package.json. Attempting bower.json"
  try require "#{env.configBase}/bower"
  catch error
    logger.verbose "Couldn't find package file"

    # Return empty package information
    name:    ''
    version: ''


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
  cwd:        argv.cwd
  configPath: argv.myappfile
  require:    argv.require
  completion: argv.completion
  (environment)->
    env = environment
    if !env.configPath
      logger.verbose chalk.red 'No SMASHFILE found'
      project = {}
    else
      logger.verbose 'Working in directory', chalk.magenta chalk.underline tildify env.cwd
      logger.verbose 'Using Smashfile', chalk.magenta chalk.underline tildify env.configPath
      process.chdir(env.configBase)
      project = require env.configPath

module.exports =
  assets:       project.assets or assets
  overrides:    project.overrides or {}
  pkg:          pkg
  env:          env
  dir:          _.defaults (project.dir or {}), assumptions.dir
  build:        project.build or assumptions.build
  compile:      project.compile or assumptions.compile
