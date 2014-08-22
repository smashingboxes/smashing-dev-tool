module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, vendorFiles, copyFiles, time, filters, dest, colors, $} = helpers
  {logger, notify, execute} = util

  tasks.add 'compile:styl', ->
    files('styl')
      .pipe($.using())
      .pipe($.stylus errors: true)
      .on('error', (err) ->
        log colors.red err.message
      )
      .pipe(dest.compile())
      # .pipe postProcessStyles()
      # .pipe $.if isVerbose, $.size title: 'stylus'
