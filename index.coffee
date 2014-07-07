#!/usr/bin/env coffee
Liftoff =     require 'liftoff'
argv =        require('minimist')(process.argv.slice 2)
chalk =       require 'chalk'

Smasher = new Liftoff
  name: 'smasher'
  processTitle: 'smasher'
  moduleName: 'smasher'
  configName: 'smashfile'
  extensions: require('interpret').jsVariants

Smasher.on 'require', (name) ->
  console.log 'Requiring external module', chalk.magenta(name)

Smasher.on 'requireFail', (name) ->
  console.log chalk.red('Failed to load external module'), chalk.magenta(name)

Smasher.launch
  cwd: argv.cwd
  configPath: argv.myappfile
  require: argv.require
  completion: argv.completion
  (env)->
    console.log('LIFTOFF SETTINGS:', this)
    console.log('CLI OPTIONS:', argv)
    console.log('CWD:', env.cwd)
    console.log('LOCAL MODULES PRELOADED:', env.require)
    console.log('SEARCHING FOR:', env.configNameRegex)
    console.log('FOUND CONFIG AT:',  env.configPath)
    console.log('CONFIG BASE DIR:', env.configBase)
    console.log('YOUR LOCAL MODULE IS LOCATED:', env.modulePath)
    console.log('LOCAL PACKAGE.JSON:', env.modulePackage)
    # console.log('CLI PACKAGE.JSON', require('./package'))
