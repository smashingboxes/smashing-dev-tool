coffeeStylish = require('coffeelint-stylish').reporter
coffeelintrc = require '../../config/lint/coffeelintrc'
lazypipe = require 'lazypipe'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util


  # postProcessScripts = lazypipe()
  #   .pipe $.header, banner

  tasks.add 'compile:coffee', ->
    {assets, env, dir, pkg, helpers} = getProject()
    {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers

    files('coffee')
      .pipe($.using())
      .pipe($.coffeelint coffeelintrc)
      .pipe($.coffeelint.reporter())
      .pipe($.coffee bare:true)
      .pipe dest.compile()
