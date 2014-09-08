gulp = require 'gulp'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  tasks.add 'compile:vendor', ->
    {assets, env, dir, pkg, helpers} = getProject()
    {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers

    vendorFiles('*')
      .pipe($.using())
      .pipe(gulp.dest "#{dir.compile}/components/vendor")
