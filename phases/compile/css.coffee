csslintrc = require '../../config/lint/csslintrc'

module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, dest, $, banner} = helpers
  {logger, notify, execute} = util

  tasks.add 'compile:css', ->
    files('css')
      .pipe($.using())
      .pipe($.csslint csslintrc)
      .pipe($.csslint.reporter())
      .pipe(dest.compile())
      # .pipe(postProcessStyles())
