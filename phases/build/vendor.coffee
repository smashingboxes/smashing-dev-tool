gulp = require 'gulp'
lazypipe = require 'lazypipe'

module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, compiledFiles, vendorFiles, copyFiles, time, filters, dest, colors, $} = helpers
  {logger, notify, execute} = util

  tasks.add 'build:vendor', ->
    vendorFiles('*')
      .pipe($.using())
      .pipe(gulp.dest "#{dir.build}/components/vendor")
