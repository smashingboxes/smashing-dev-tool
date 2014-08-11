{files, dest, banner, $, lazypipe} = require('../../config/helpers')
{logger, notify, execute} = require('../../config/util')
{assets, tasks, args, dir, pkg} = require('../../config/config')

csslintrc = require '../../config/lint/csslintrc'

tasks.add 'compile:css', ->
  files('css')
    .pipe($.using())
    .pipe($.csslint csslintrc)
    .pipe($.csslint.reporter())
    .pipe(dest.compile())
    # .pipe(postProcessStyles())
