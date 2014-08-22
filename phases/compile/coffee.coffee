coffeeStylish = require('coffeelint-stylish').reporter
coffeelintrc = require '../../config/lint/coffeelintrc'
lazypipe = require 'lazypipe'

module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, dest, $, banner} = helpers
  {logger, notify, execute} = util

  # postProcessScripts = lazypipe()
  #   .pipe $.header, banner

  tasks.add 'compile:coffee', ->
    files('coffee')
      .pipe($.using())
      .pipe($.coffeelint coffeelintrc)
      .pipe($.coffeelint.reporter())
      .pipe($.coffee bare:true)
      .pipe dest.compile()
