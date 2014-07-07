
gulp =            require 'gulp'
$ =               require('gulp-load-plugins')(camelize: true)  # attach  "gulp-*" plugins to '$' variable
$.util =          require 'gulp-util'
bowerRequireJS =  require 'bower-requirejs'

helpers =         require './helpers'
{
  isQa
  isVerbose
  isBundled
  isOptimized
  base64Images
  isWatching
} = helpers

# <br><br><br>


###
**[Karma](https://github.com/karma-runner/karma)**

Karma is a simple tool that allows you to execute JavaScript code in
multiple real browsers. We use it to run our tests across major
browsers of interest
###
karma:
  files:[
    {pattern: '**/*.js', included: false},
    {pattern: '**/*.coffee', included: false},
    {pattern: '**/*.html', included: false},
    {pattern: '**/*.jade', included: false},
    {pattern: '**/*.css', included: false},
    {pattern: '**/*.styl', included: false},
  ]
  exclude: 'components/vendor/*'
# <br><br><br>





###
<h2>Testing</h2>
###

exports.runAll = ->
  options =
    config: 'config/karma.bootstrap.js'
    # exclude: ['underscore', 'jquery']
    transitive: true

  # Inject vendor assets into Require config for testing
  bowerRequireJS options, (rjsConfigFromBower) ->
    gulp.src ['undefined.js']
      .pipe $.if isVerbose, $.using()
      .pipe($.karma(
        configFile: 'config/karma.config.coffee'
        action: 'run'
      )).on 'error', (err) ->
        console.log err
        # Make sure failed tests cause gulp to exit non-zero
        # throw err

# ###
# Test through Karma
# ###
# test =
#   # Watch specs for changes and run tests on change
#   watch: ->
#     gulp.watch paths.spec + "**/*.coffee", ["test-compile"]
#     test.go "watch"
#
#   compile: ->
#     run ['compile:all']
#
#   # Run the tests once
#   run: ->
#     test.compile()
#     test.go "run"
#
#   # Test run/watch helper: either runs or launches a single test
#   go: (action) ->
#     files = ["undefined.js"]
#     gulp.src(files).pipe karma(
#       configFile: "karma.conf.js"
#       action: action
#     )
#
