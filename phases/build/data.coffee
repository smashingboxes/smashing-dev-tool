
module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, compiledFiles, vendorFiles, copyFiles, time, filters, dest, colors, $} = helpers
  {logger, notify, execute} = util

  tasks.add 'build:data', (done) ->
    compiledFiles('py')
      .pipe($.using())
      .pipe(dest.build())
