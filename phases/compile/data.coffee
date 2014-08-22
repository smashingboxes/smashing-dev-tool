
module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, vendorFiles, copyFiles, time, filters, dest, colors, $} = helpers
  {logger, notify, execute} = util

  tasks.add 'compile:data', (done) ->
    files('py')
      .pipe($.using())
      .pipe(dest.compile())
