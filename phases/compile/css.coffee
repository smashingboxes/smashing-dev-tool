csslintrc = require '../../config/lint/csslintrc'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  tasks.add 'compile:css', ->
    {assets, env, dir, pkg, helpers} = getProject()
    {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers

    files('css')
      .pipe($.using())
      .pipe($.csslint csslintrc)
      .pipe($.csslint.reporter())
      .pipe(dest.compile())
      # .pipe(postProcessStyles())
