{files, dest, banner, $, lazypipe} = require('../../config/helpers')
{logger, notify, execute} = require('../../config/util')
{assets, tasks, args, dir, pkg} = require('../../config/config')


tasks.add 'compile:data', (done) ->
  files('py')
    .pipe($.using())
    .pipe(dest.compile())
