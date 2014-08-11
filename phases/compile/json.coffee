{files, dest, banner, $, lazypipe} = require('../../config/helpers')
{logger, notify, execute} = require('../../config/util')
{assets, tasks, args, dir, pkg} = require('../../config/config')


tasks.add 'compile:json', ->
  files('json')
    .pipe($.using())
    .pipe($.jsonlint())
    .pipe($.jsonlint.reporter())
    .pipe(dest.compile())
