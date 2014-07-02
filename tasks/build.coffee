_ =               require 'lodash'                # array and object utilities
bowerRequireJS =  require 'bower-requirejs'
lazypipe =        require 'lazypipe'              # re-use partial streams
combine =         require 'stream-combiner'
run =             require 'run-sequence'          # execute tasks in parallel or series

gulp =            require 'gulp'
$ =               require('gulp-load-plugins')(camelize: true)
$.util =          require 'gulp-util'

coffeeStylish =   require('coffeelint-stylish').reporter  # pretty coffeelint output
jsStylish =       require 'jshint-stylish'        # pretty jshint output


# Load build configuration
cfg =             require '../build.config'
rconfig =         require '../build.require'
{
  execute
  banner
  copyFiles
  files
  vendorFiles
  compiledFiles
  time
  filters
  dest
  colors
  log
  sync
  notify
  currentDir
  isQa
  isVerbose
  isBundled
  isOptimized
  base64Images
  isWatching
  isSyncing
  USER
  APP_NAME
  BUILD_TIME
  APP_VERSION_SRC
  APP_VERSION
  APP_VERSION_AS_URL
  STACKATO_APP_ID
} = helpers = require './helpers'

compileMode =     helpers.isCompiling or false
buildMode =       helpers.isBuilding or false
# <br><br><br>




gulp.task 'build:all', (done) ->
  log ''
  log colors.bold '[BUILDING APP]'
  log.alt isOptimized,     "Optimization:       "
  log colors.green         "    css2js             ✔ "  if isOptimized
  log colors.green         "    ng-html2js         ✔ "  if isOptimized
  log colors.green         "    closure compiler   ✔ "  if isOptimized
  log.alt isBundled,       "Bundle Assets:      "
  log colors.green         "    requireJS          ✔ "  if isBundled

  notify 'Build', 'Building app assets...'
  run 'build:vendor', [
    'build:styles'
    'build:views'
    'build:data'
    'build:images'
  ], 'build:scripts', ->
    notify 'Build', 'App built successfully!'
    done()

gulp.task 'compile:all', (done) ->
  log ''
  log colors.bold '[COMPILING APP ASSETS]'
  log colors.green         "Code Quality:"              unless buildMode
  log colors.green         "    linting/hinting    ✔ "  unless buildMode

  notify 'Compile', 'Compiling app assets...'
  run [
    'compile:vendor'
    'compile:views'
    'compile:styles'
    'compile:scripts'
    'compile:data'
    ], ->
      notify 'Compile', 'Assets compiled successfully!'
      done()

gulp.task 'clean:compile', ->
  gulp.src cfg.compileDir
   .pipe $.rimraf cfg.tasks.rimraf

gulp.task 'clean:build', ->
  gulp.src cfg.buildDir
   .pipe $.rimraf cfg.tasks.rimraf
# <br><br><br>





###
<h2>Scripts<h2>
###

devBanner = lazypipe()
  .pipe $.header, banner

optimizeScripts = lazypipe()
  .pipe $.stripDebug
  .pipe $.uglify, cfg.tasks.uglify

postProcessScripts = lazypipe()
  # .pipe $.ngmin
  .pipe $.header, banner


gulp.task 'compile:coffee', ->
  log.tag 'compile', 'coffee'
  files('coffee')
    .pipe $.if isVerbose, $.using()
    .pipe $.coffeelint cfg.tasks.coffeelint
    .pipe $.coffeelint.reporter()
    .pipe $.coffee cfg.tasks.coffee
    .pipe postProcessScripts()
    # .pipe $.if isVerbose, $.size title: 'coffeescript'
    .pipe dest.compile()

gulp.task 'compile:js', ->
  log.tag 'compile', 'js'
  files('js')
    .pipe $.if isVerbose, $.using()
    .pipe $.jshint cfg.tasks.jshint
    .pipe $.jshint.reporter jsStylish
    .pipe postProcessScripts()
    # .pipe $.if isVerbose, $.size title: 'javascript'
    .pipe dest.compile()

gulp.task 'compile:scripts', (done) ->
  run ['compile:js', 'compile:coffee'], done

gulp.task 'build:scripts', (done)->
  log.tag 'build', 'scripts'
  compiledFiles('js')
    # .pipe optimizeScripts()
    .pipe dest.build()

  # if isBundled
  #   # Inject vendor assets into Require config
  #   bowerRequireJS cfg.tasks.bowerRequire, (rjsConfigFromBower) ->
  #     $.requirejs(rconfig)
  #       .pipe optimizeScripts()
  #       .pipe dest.build()
  # else
  #   run 'build:vendor', ->
  #      compiledFiles('js')
  #        .pipe dest.build()





###
<h2>Styles</h2>
###

# add polyfills, 3rd-pary libs
postProcessStyles = lazypipe()
  .pipe $.myth, cfg.tasks.myth

# minify .css
optimizeStyles = lazypipe()
  .pipe $.csso, cfg.tasks.csso

# convert .css to .js for self-injecting style element
bundleStyles = lazypipe()
  .pipe $.concat, 'app-styles.css'
  .pipe $.css2js
  .pipe $.wrapAmd

gulp.task 'compile:css', ->
  log.tag 'compile', 'css'
  files('css')
    .pipe $.if isVerbose, $.using()
    .pipe $.csslint cfg.tasks.csslint
    .pipe $.csslint.reporter()
    .pipe postProcessStyles()
    # .pipe $.if isVerbose, $.size title: 'css'
    .pipe dest.compile()

gulp.task 'compile:styl', ->
  log.tag 'compile', 'stylus'
  files('styl')
    .pipe $.if isVerbose, $.using()
    .pipe $.stylus cfg.tasks.stylus
    .on 'error', (err) ->
      log colors.red err.message
    .pipe postProcessStyles()
    # .pipe $.if isVerbose, $.size title: 'stylus'
    .pipe dest.compile()

gulp.task 'compile:styles', (done) ->
  run ['compile:css', 'compile:styl'], done

gulp.task 'build:styles', ->
  log.tag 'build', 'styles'
  compiledFiles('css')
    .pipe $.if isVerbose, $.using()
    .pipe optimizeStyles()
    .pipe bundleStyles()
    .pipe $.if isVerbose, $.using()
    .pipe dest.build()





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

gulp.task 'compile:html', ->
  log.tag 'compile', 'html'
  files('html')
    .pipe $.if isVerbose, $.using()
    .pipe $.htmlhint cfg.tasks.htmlhint
    .pipe $.htmlhint.reporter()
    # .pipe $.if isVerbose, $.size title: 'html'
    .pipe dest.compile()


$.scp =           require '../plugins/gulp-stackato-sync'
gulp.task 'compile:jade', ->
  log.tag 'compile', 'jade'
  files('jade')
    .pipe $.if isVerbose, $.using()
    .pipe $.jade()
    # .pipe $.if isVerbose, $.size title: 'jade'
    .pipe dest.compile()

gulp.task 'compile:json', ->
  log.tag 'compile', 'json'
  files('json')
    .pipe $.if isVerbose, $.using()
    .pipe $.jsonlint()
    .pipe $.jsonlint.reporter()
    # .pipe $.if isVerbose, $.size title: 'json'
    .pipe dest.compile()

gulp.task 'compile:views', (done) ->
  run ['compile:html', 'compile:jade', 'compile:json'], done

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




###
<h2>Images</h2>
###

# _optimizeImages_
optimizeImages = lazypipe()
  .pipe $.imagemin, cfg.tasks.imagemin

# _encodeImages_
encodeImages = lazypipe()
  .pipe $.imacss, cfg.tasks.imacss

gulp.task 'build:images', ->
  log.tag 'build', 'images'
  files('gif', 'jpg', 'png', 'svg')
    .pipe $.if isVerbose, $.using()
    .pipe optimizeImages()
    # .pipe $.if base64Images, encodeImages()
    .pipe dest.build()
# <br><br><br>




###
<h2>Vendor</h2>
###
gulp.task 'compile:vendor', ->
  log.tag 'compile', 'vendor'
  vendorFiles('*')
    .pipe $.if isVerbose, $.using()
    .pipe gulp.dest "#{cfg.compileDir}/components/vendor"

gulp.task 'build:vendor', ->
  log.tag 'build', 'vendor'
  vendorFiles('*')
    .pipe $.if isVerbose, $.using()
    .pipe gulp.dest "#{cfg.buildDir}/components/vendor"

gulp.task 'install:vendor', (done) ->
  execute 'bower install', done
# <br><br><br>




###
<h2>Data</h2>
###
gulp.task 'compile:data', (done) ->
  log.tag 'compile', 'data'
  files('py')
    .pipe $.if isVerbose, $.using()
    .pipe dest.compile()

gulp.task 'build:data', (done) ->
  log.tag 'build', 'data'
  compiledFiles('py')
    .pipe $.if isVerbose, $.using()
    .pipe dest.build()
# <br><br><br>
