{files, dest, banner, $, lazypipe} = require('../../config/helpers')
{logger, notify, execute} = require('../../config/util')
{assets, tasks, args, dir, pkg} = require('../../config/config')
jsStylish = require 'jshint-stylish'
jshintrc = require '../../config/lint/jshintrc'



tasks.add 'compile:js', ->
  files('js')
    .pipe($.using())
    .pipe($.jshint jshintrc)
    .pipe($.jshint.reporter jsStylish)
    .pipe dest.compile()
