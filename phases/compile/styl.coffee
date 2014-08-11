{files, dest, banner, $, lazypipe} = require('../../config/helpers')
{logger, notify, execute} = require('../../config/util')
{assets, tasks, args, dir, pkg} = require('../../config/config')


tasks.add 'compile:styl', ->
  files('styl')
    .pipe($.using())
    .pipe($.stylus errors: true)
    .on('error', (err) ->
      log colors.red err.message
    )
    .pipe(dest.compile())
    # .pipe postProcessStyles()
    # .pipe $.if isVerbose, $.size title: 'stylus'
