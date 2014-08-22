

module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, vendorFiles, copyFiles, time, filters, dest, colors, $} = helpers
  {logger, notify, execute} = util


  tasks.add 'compile:json', ->
    files('json')
      .pipe($.using())
      .pipe($.jsonlint())
      .pipe($.jsonlint.reporter())
      .pipe(dest.compile())
