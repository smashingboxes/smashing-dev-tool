{files, dest, banner, $, lazypipe} = require('../../config/helpers')
{logger, notify, execute} = require('../../config/util')
{assets, tasks, args, dir, pkg} = require('../../config/config')

htmlhintrc = require '../../config/lint/htmlhintrc'

tasks.add 'compile:html', ->
  files('html')
    .pipe($.using())
    .pipe($.htmlhint htmlhintrc)
    .pipe($.htmlhint.reporter())
    .pipe(dest.compile())
