# Generates config from relavent global enviornment information

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

# smasher
smashRoot = process.mainModule.filename.replace '/bin/smash', ''
smashPkg  = require "#{smashRoot}/package"
util      = {logger, notify, execute} = require '../utils/util'

tasks     = new Orchestrator()
recipes   = {}
Recipe    = require('../utils/recipe.coffee')
assets    = require './assets'


# # Collect recipe formulae
# for recipe in ['coffee', 'js', 'styl', 'css', 'jade', 'html', 'json', 'vendor', 'images', 'fonts']
#   recipes[recipe] = require("../recipes/#{recipe}")(globalConfig)
#
# # Build required asset tasks based on project Smashfile
# assetTasks = ("#{ext}" for ext, asset of assets).concat ['vendor', 'images']


# User information
getUser = ->
  gitConfig = require('git-config').sync()
  user = gitConfig.user or {}
  user.homeDir =  process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE
  user.username = if gitConfig.github?.user? then gitConfig.github.user else user.homeDir?.split("/").pop() or 'root'

getPlatform = ->
  type:               os.type()
  platform:           os.platform()
  hostname:           os.hostname()
  arch:               os.arch()
  release:            os.release()
  EOL:                os.EOL
  cpus:               os.cpus()
  networkInterfaces:  os.networkInterfaces()

# Add a Task (Orchestrator)
addTask = ->
  logger.verbose "Registering a new task: #{chalk.cyan arguments[0]}"
  tasks.add.apply tasks, arguments

# Add a Recipe (Gulp)
addRecipe = (recipe={}) ->
  ext = if _.isArray recipe.ext then recipe.name else recipe.ext
  recipes[ext] = r = new Recipe recipe
  logger.verbose "Registering a recipe for #{chalk.magenta ext}"

  addWatchTask = (target) ->
    task = "target:#{ext}"
    glob = "#{target}/**/*#{ext}"

    tasks.add task, recipe[target]
    gulp.task task, recipe[target]
    r.watch = ->
      gulp.watch compileGlob, (if recipe.reload then [task, $.reload] else [task])

  addWatchTask 'compile'
  addWatchTask 'biild'
  r

# Add a Command (commander.js)
addCommand = (name) ->
  logger.verbose "Registering
   command '#{chalk.cyan name}'"
  if name?
    commander.command name
  else
    commander


class smasher
  constructor: ->
    logger.verbose "Creating new #{chalk.bold.red 'smasher'}!"
    @pkg         = smashPkg
    @rootPath    = smashRoot

    @assets      = assets
    @assumptions = require './assumptions'
    @project     = require './project'

    @user        = getUser()
    @platform    = getPlatform()
    @util        = util
    @args        = argv


    @tasks       = tasks
    @recipes     = recipes
    @commander   = commander

  load: (extension) ->
    logger.info "Loading module for .#{extension} files"  if argv.verbose
    root = @rootPath
    require("#{@rootPath}/recipes/#{extension}")



  task: addTask
  recipe: addRecipe
  command: addCommand

smasher::smasher = smasher
module.exports = new smasher
