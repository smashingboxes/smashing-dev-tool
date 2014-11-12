# Generates config from relavent global enviornment information

argv =          require('minimist')(process.argv.slice 2)
chalk =         require 'chalk'
fs =            require 'fs'
os =            require 'os'
gitConfig =     require 'git-config'
Orchestrator =  require 'orchestrator'
commander =     require 'commander'
_ =             require 'underscore'
_str =          require 'underscore.string'

# Smasher
smashRoot =     process.mainModule.filename.replace '/bin/smash', ''
smashPkg =      require "#{smashRoot}/package"
assumptions =   require './assumptions'
util =          require './util'
{logger, notify, execute} = util


# User
config = gitConfig.sync()
user = config.user or {}
user.homeDir = homeDir =   process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE
user.username = if config.github?.user? then config.github.user else homeDir?.split("/").pop() or 'root'
format = (s) -> s.toLowerCase().replace /\s/g, ''


# Platform
platform =
  type:               os.type()
  platform:           os.platform()
  hostname:           os.hostname()
  arch:               os.arch()
  release:            os.release()
  EOL:                os.EOL
  cpus:               os.cpus()
  networkInterfaces:  os.networkInterfaces()

finalConfig =
  args:         argv
  util:         util
  assumptions:  assumptions
  commander:    commander
  tasks:        new Orchestrator()
  fileRecipes:      {}
  user:         user
  platform:     platform
  smash:
    pkg:        smashPkg
    root:       smashRoot

project = null
finalConfig.getProject = ->
  unless project
    project = require './project'
  project

module.exports = finalConfig
