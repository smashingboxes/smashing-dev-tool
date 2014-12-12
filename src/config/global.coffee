
gulp         = require 'gulp'
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

util         = {args, logger, notify, execute} = require '../utils/util'
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
    logger.verbose "Creating new #{chalk.bold.red 'smasher'}!"  if args.verbose
    @pkg         = smashPkg
    @rootPath    = smashRoot

    @assets      = []
    @assumptions = require './assumptions'
    @project     = require './project'

    @user        = getUser()
    @platform    = getPlatform()
    @util        = util
    @args        = args

    @tasks       = tasks
    @recipes     = recipes
    @commander   = commander
    @modules = []

  # Load/register components by name
  load: (type, name) ->
    root = @rootPath
    switch type
      when 'recipe'
        unless @recipes[name]
          logger.verbose "Loading recipe: #{chalk.blue name}"
          require "#{@rootPath}/src/recipes/#{name}"
        else
          logger.warn "Reccipe #{chalk.red name} is already registered"

      when 'module'
        unless _.findWhere(@modules, name:name)
          logger.verbose "Loading module: #{chalk.red name}"
          require "#{@rootPath}/src/modules/#{name}"
        else
          logger.warn "Module #{chalk.red name} is already registered"

  loadModule: (name) -> @load 'module', name
  loadRecipe: (name) -> @load 'recipe', name


  # Initialize the module(s) needed for the given command
  initCmd: (cmd) ->
    if mod = (_.find @modules, (m) -> _.contains m.commands, cmd)
      tasks.start "load-module:#{mod.name}"
    else
      logger.error 'Could not find command' if cmd
      @commander.help()


  # Register a Task (Orchestrator)
  task: ->
    logger.verbose "Registering #{chalk.yellow 'task'} #{chalk.cyan arguments[0]}"
    tasks.add.apply tasks, arguments

  # Add a Recipe (Gulp)
  recipe: (recipe={}) ->
    ext = if _.isArray recipe.ext then recipe.name else recipe.ext
    logger.verbose "Registering #{chalk.yellow 'recipe'} for #{chalk.magenta ext}"
    recipes[ext] = r = new Recipe recipe



  # Register a Command (commander.js)
  command: (name) ->
    logger.verbose "Registering
     #{chalk.yellow 'command'} '#{chalk.cyan name}'"
    if name? then commander.command name else commander

  # Register a module that will create tasks and commands
  module: (mod={}) ->
    self = @
    console.log _.contains @modules, mod
    unless _.findWhere(@modules, name:mod.name)?
      logger.info "Registering module: #{chalk.red mod.name}"  if args.verbose
      @modules.push mod

      {dependencies, name} = mod
      lDeps = if dependencies? then ("load-module:#{d}" for d in dependencies) else []
      lName = "load-module:#{name}"

      self.task lName, lDeps, (done) ->
        mod.init.call self, self
        done()



smasher::smasher = smasher
module.exports = new smasher
