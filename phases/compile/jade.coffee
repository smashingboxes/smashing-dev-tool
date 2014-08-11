{files, dest, banner, $, lazypipe} = require('../../config/helpers')
{logger, notify, execute} = require('../../config/util')
{assets, tasks, args, dir, pkg} = require('../../config/config')

tasks.add 'compile:jade', ->
  files('jade')
    .pipe($.using())
    .pipe($.jade())
    .pipe(dest.compile())
