htmlhintrc = require '../../config/lint/htmlhintrc'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  tasks.add 'compile:html', ->
    {assets, env, dir, pkg, helpers} = getProject()
    {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers

    files('html')
      .pipe($.using())
      .pipe($.htmlhint htmlhintrc)
      .pipe($.htmlhint.reporter())
      .pipe(dest.compile())
