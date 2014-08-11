{compiledFiles, dest, banner, $, lazypipe} = require('../../config/helpers')
{logger, notify, execute} = require('../../config/util')
{assets, tasks, args, dir, pkg} = require('../../config/config')



tasks.add 'build:data', (done) ->
  compiledFiles('py')
    .pipe($.using())
    .pipe(dest.build())
