###
**<h5>[gulp-ng-html2js](https://github.com/marklagendijk/gulp-ng-html2js)</h5>**

Generates AngularJS modules which pre-load your HTML code into the $templateCache.
###
ngHtml2js:
  moduleName: "views"
  prefix: ''
# <br><br><br>


###
<h2>Views</h2>
###

# minify .html
optimizeViews = lazypipe()
  .pipe $.htmlmin, collapseWhitespace: true

# package Angular templates together as .js
bundleViews = lazypipe()
  .pipe $.ngHtml2js, cfg.tasks.ngHtml2js
  .pipe $.concat, 'app-views.js'
  .pipe $.wrapAmd

gulp.task 'build:views', ->
  log.tag 'build', 'views'
  compiledFiles('html')
    .pipe $.if isVerbose, $.using()
    .pipe optimizeViews()
    # .pipe bundleViews()
    # .pipe $.if isVerbose, $.size title: 'views'
    .pipe $.if isVerbose, $.using()
    .pipe dest.build()
    .pipe compiledFiles('json')
    .pipe $.if isVerbose, $.using()

    .pipe dest.build()
