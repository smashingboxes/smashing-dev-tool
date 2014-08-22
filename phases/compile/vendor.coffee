gulp = require 'gulp'

module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, vendorFiles, copyFiles, time, filters, dest, colors, $} = helpers
  {logger, notify, execute} = util

  tasks.add 'compile:vendor', ->
    vendorFiles('*')
      .pipe($.using())
      .pipe(gulp.dest "#{dir.compile}/components/vendor")
