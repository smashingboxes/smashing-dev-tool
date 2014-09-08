module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  tasks.add 'compile:styl', ->
    {assets, env, dir, pkg, helpers} = getProject()
    {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers

    files('styl')
      .pipe($.using())
      .pipe($.stylus errors: true)
      .on('error', (err) ->
        log colors.red err.message
      )
      .pipe(dest.compile())
      # .pipe postProcessStyles()
      # .pipe $.if isVerbose, $.size title: 'stylus'
