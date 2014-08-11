{compiledFiles, dest, banner, $, lazypipe} = require('../../config/helpers')
{logger, notify, execute} = require('../../config/util')
{assets, tasks, args, dir, pkg} = require('../../config/config')

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
