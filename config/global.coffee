
gulp         = require 'gulp'
argv         = require('minimist')(process.argv.slice 2)
chalk        = require 'chalk'
fs           = require 'fs'
os           = require 'os'
Orchestrator = require 'orchestrator'
commander    = require 'commander'
_            = require 'underscore'
_str         = require 'underscore.string'
dir          = require 'require-dir'
browserSync  = require 'browser-sync'
reload       = browserSync.reload

util         = {logger, notify, execute} = require '../utils/util'
tasks        = new Orchestrator()
recipes      = {}
Recipe       = require('../utils/recipe')

smashRoot    = process.mainModule.filename.replace '/bin/smash', ''
smashPkg     = require "#{smashRoot}/package"


# User information
getUser = ->
  gitConfig = require('git-config').sync()
  user = gitConfig.user or {}
  user.homeDir =  process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE
  user.username = if gitConfig.github?.user? then gitConfig.github.user else user.homeDir?.split("/").pop() or 'root'

# Platform details
getPlatform = ->
  type:               os.type()
  platform:           os.platform()
  hostname:           os.hostname()
  arch:               os.arch()
  release:            os.release()
  EOL:                os.EOL
  cpus:               os.cpus()
  networkInterfaces:  os.networkInterfaces()



# Central smasher instance
class smasher
  constructor: ->
    logger.verbose "Creating new #{chalk.bold.red 'smasher'}!"  if argv.verbose
    @pkg         = smashPkg
    @rootPath    = smashRoot

    @assets      = []
    @assumptions = require './assumptions'
    @project     = require './project'

    @user        = getUser()
    @platform    = getPlatform()
    @util        = util
    @args        = argv._

    @tasks       = tasks
    @recipes     = recipes
    @commander   = commander
    @modules = []

  # Load/register recipes by file type
  load: (extension) ->
    logger.info "Loading module for #{extension} files"  if argv.verbose
    root = @rootPath
    require("#{@rootPath}/recipes/#{extension}")

  # Load a module by name
  loadModule: (name) ->
    logger.info "Loading module: #{chalk.red name}"  if argv.verbose
    require("../modules/#{name}")

  # initialize the module for the given command
  initCmd: (cmd) ->
    self = @
    if _.chain(@modules).pluck('commands').flatten().contains(cmd).value()
      if mod = (_.find @modules, (m) -> _.contains m.commands, cmd)
        if mod.dependencies
          for dep in mod.dependencies
            d = _.findWhere(@modules, name: dep)
            d.init.call self, self
        mod.init.call self, self
        return

    logger.error 'Could not find command'
    @commander.help()

  # Add a Task (Orchestrator)
  task: ->
    logger.verbose "Registering #{chalk.yellow 'task'} #{chalk.cyan arguments[0]}"
    tasks.add.apply tasks, arguments

  # Add a Recipe (Gulp)
  recipe: (recipe={}) ->
    ext = if _.isArray recipe.ext then recipe.name else recipe.ext
    recipes[ext] = r = new Recipe recipe
    logger.verbose "Registering #{chalk.yellow 'recipe'} for #{chalk.magenta ext}"

  # Add a Command (commander.js)
  command: (name) ->
    logger.verbose "Registering
     #{chalk.yellow 'command'} '#{chalk.cyan name}'"
    if name? then commander.command name else commander

  module: (mod={}) ->
    logger.info "Registering module: #{chalk.red mod.name}"  if argv.verbose
    @modules.push mod


smasher::smasher = smasher
module.exports = new smasher
