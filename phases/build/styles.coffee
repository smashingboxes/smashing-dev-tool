lazypipe = require 'lazypipe'

module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, compiledFiles, vendorFiles, copyFiles, time, filters, dest, colors, $} = helpers
  {logger, notify, execute} = util

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

  tasks.add 'build:styles', ->
    compiledFiles('css')
      .pipe($.using())
      .pipe(optimizeStyles())
      .pipe(bundleStyles())
      .pipe($.using())
      .pipe(dest.build())
