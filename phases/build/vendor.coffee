gulp = require 'gulp'
lazypipe = require 'lazypipe'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  tasks.add 'build:vendor', ->
    {assets, env, dir, pkg, helpers} = getProject()
    {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers
    
    vendorFiles('*')
      .pipe($.using())
      .pipe(gulp.dest "#{dir.build}/components/vendor")
