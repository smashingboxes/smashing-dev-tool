module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, vendorFiles, copyFiles, time, filters, dest, colors, $} = helpers
  {logger, notify, execute} = util

  tasks.add 'compile:jade', ->
    files('jade')
      .pipe($.using())
      .pipe($.jade())
      .pipe(dest.compile())
