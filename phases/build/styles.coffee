{compiledFiles, dest, banner, $, lazypipe} = require('../../config/helpers')
{logger, notify, execute} = require('../../config/util')
{assets, tasks, args, dir, pkg} = require('../../config/config')


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
