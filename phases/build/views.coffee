lazypipe = require 'lazypipe'

module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, compiledFiles, vendorFiles, copyFiles, time, filters, dest, colors, $} = helpers
  {logger, notify, execute} = util

  cfg =
    ngHtml2js:
      moduleName: "views"
      prefix: ''

  optimizeViews = lazypipe()
    .pipe $.htmlmin, collapseWhitespace: true

  bundleViews = lazypipe()
    .pipe($.ngHtml2js, cfg.ngHtml2js)
    .pipe($.concat, 'app-views.js')
    .pipe($.wrapAmd)

  tasks.add 'build:views', ->
    compiledFiles('html')
      # .pipe($.using())
      .pipe(optimizeViews())
      .pipe(bundleViews())
      .pipe($.using())
      .pipe(dest.build())
      .pipe(compiledFiles('json'))
      .pipe($.using())
      .pipe(dest.build())
