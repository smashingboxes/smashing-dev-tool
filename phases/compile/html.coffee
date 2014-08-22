htmlhintrc = require '../../config/lint/htmlhintrc'

module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, vendorFiles, copyFiles, time, filters, dest, colors, $} = helpers
  {logger, notify, execute} = util



  tasks.add 'compile:html', ->
    files('html')
      .pipe($.using())
      .pipe($.htmlhint htmlhintrc)
      .pipe($.htmlhint.reporter())
      .pipe(dest.compile())
