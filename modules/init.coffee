

smasher = require '../config/global'
smasher.module
  name:     'init'
  commands: ['setup', 'run']

  init: (smasher) ->
    {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = smasher
    {logger, notify, execute} = util


    ### ---------------- COMMANDS ------------------------------------------- ###
    # Setup
    commander
      .command('setup')
      .description('set up project to use the smasher')
      .option('-b, --bold',         'Display detailed log information')
      .action(->
        {assets, env, dir, pkg, helpers} = getProject()
        {files, vendorFiles, compiledFiles,  banner, dest, time, $} = helpers

        console.log 'setup'
      ).on '--help', ->
        console.log '  Examples:'
        console.log ''
        console.log '    $ deploy exec sequential'
        console.log '    $ deploy exec async'
        console.log ''

    # Run
    commander
      .command('run')
      .description('run remote setup commands')
      .option('-b, --bold', 'make it bold!')
      .usage('[options] files...')
      .on('--help', ->
        console.log '  Examples:'
        console.log ''
        console.log '    $ deploy exec sequential'
        console.log '    $ deploy exec async'
        console.log ''
      )
      .action(->
        console.log 'running..'
      )
