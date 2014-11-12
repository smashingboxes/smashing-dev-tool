gulp =      require 'gulp'
del =       require 'del'


module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util


  ### ---------------- COMMANDS ------------------------------------------- ###
  commander
    .command('build')
    .description('build local assets based on Smashfile')
    .action ->
      # tasks.start [
      #   'build:scripts'
      #   'build:styles'
      #   'build:vendor'
      #   'build:views'
      #   'build:data'
      #   'build:images'
      # ]


  ### ---------------- TASKS ------------------------------ ---------------- ###
  tasks.add 'build:watch', ->
    args.watch = true
    # tasks.start [
    #   'build:scripts'
    #   'build:styles'
    #   'build:vendor'
    #   'build:views'
    #   'build:data'
    #   'build:images'
    # ]

  tasks.add 'build:clean', (done) ->
    {assets, env, dir, pkg, helpers} = getProject()
    del [dir.build], done
