module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  tasks.add 'compile:jade', ->
    {assets, env, dir, pkg, helpers} = getProject()
    {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers

    files('jade')
      .pipe($.using())
      .pipe($.jade())
      .pipe(dest.compile())
