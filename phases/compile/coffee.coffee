{files, dest, banner, $, lazypipe} = require('../../config/helpers')
{logger, notify, execute} = require('../../config/util')
{assets, tasks, args, dir, pkg} = require('../../config/config')

coffeeStylish = require('coffeelint-stylish').reporter
coffeelintrc = require '../../config/lint/coffeelintrc'

postProcessScripts = lazypipe()
  .pipe $.header, banner

tasks.add 'compile:coffee', (done) ->
  files('coffee')
    .pipe($.using())
    .pipe($.coffeelint coffeelintrc)
    .pipe($.coffeelint.reporter())
    .pipe($.coffee bare:true)
    .pipe dest.compile()
