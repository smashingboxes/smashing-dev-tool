lazypipe = require 'lazypipe'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  tasks.add 'build:styles', ->
    {assets, env, dir, pkg, helpers} = getProject()
    {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers

    cfg =
      csso: false # set to true to prevent structural modifications
      css2js:
        splitOnNewline: true
        trimSpacesBeforeNewline: true
        trimTrailingNewline: true
      myth:
        sourcemap: false

    postProcessStyles = lazypipe()
      .pipe $.myth, cfg.myth

    optimizeStyles = lazypipe()
      .pipe $.csso, cfg.csso

    bundleStyles = lazypipe()
      .pipe($.concat, 'app-styles.css')
      .pipe($.css2js)
      .pipe($.wrapAmd)

    compiledFiles('css')
      .pipe($.using())
      .pipe(optimizeStyles())
      .pipe(bundleStyles())
      .pipe($.using())
      .pipe(dest.build())
