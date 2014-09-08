lazypipe = require 'lazypipe'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util


  tasks.add 'build:views', ->
    {assets, env, dir, pkg, helpers} = getProject()
    {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers

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

    compiledFiles('html')
      # .pipe($.using())
      .pipe(optimizeViews())
      .pipe(bundleViews())
      .pipe($.using())
      .pipe(dest.build())
      .pipe(compiledFiles('json'))
      .pipe($.using())
      .pipe(dest.build())
