module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util


  ### ---------------- COMMANDS ------------------------------------------- ###
  # Setup
  commander
    .command('setup')
    .description('set up project to use the Smasher')
    .option('-b, --bold',         'Display detailed log information')
    .action(->
      {assets, env, dir, pkg, helpers} = getProject()
      {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers

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
