cfg = require './build.config'

# Karma configuration
module.exports = (config) ->
  config.set

    # base path, that will be used to resolve files and exclude
    basePath: "../#{cfg.compileDir}"

    plugins: [
      'karma-requirejs'
      'karma-jasmine'
      'karma-coverage'
      'karma-ng-html2js-preprocessor-requirejs'
      'karma-chrome-launcher'
      'karma-phantomjs-launcher'
      'karma-growl-reporter'
      'karma-osx-reporter'
    ]

    frameworks: ['requirejs', 'jasmine']

    # test results reporter to use
    # possible values: dots || progress
    reporters: ['dots', 'coverage', 'osx']

    ### Configure Karma run ###

    # To make Karma serve HTML templates, we have to use a preprocessor that turns HTML
    # templates into JavaScript strings and registers them with Angular’s $templateCache.
    preprocessors:
      '**/*.html':   ['ng-html2js']
      '**/*.js':     ['coverage']

    # list of files / patterns to load in the browser
    files: [
      '../config/karma.bootstrap.js'
      {pattern: '**/*.js', included: false}
      {pattern: '**/*.html', included: false}
      {pattern: '**/*.json', included: false}
    ]

    # list of files / patterns to exclude from files array
    exclude: []


    port: 9876        # web server port
    colors: true      # enable / disable colors in the output (reporters and logs)
    autoWatch: true   # enable / disable watching file and executing tests whenever any file changes

    # level of logging
    # possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
    logLevel: config.LOG_INFO

    # Start these browsers, currently available:
    # - Chrome
    # - ChromeCanary
    # - Firefox
    # - Opera
    # - Safari
    # - PhantomJS
    browsers: ['PhantomJS']

    # Continuous Integration mode
    # if true, it capture browsers, run tests and exit
    singleRun: true



    # Configure ng-html2js preprocessor to compile HTML views for the
    # templateCache
    ngHtml2JsPreprocessor:
      # strip this from the file path
      # stripPrefix: 'app',
      # prepend this to the
      # prependPrefix: 'served/',

      # or define a custom transform function
      # cacheIdFromPath: function(filepath) {
      #   console.log(filepath)
      #   return;
      # },
      enableRequireJs: true

      # setting this option will create only a single module that contains templates
      # from all the files, so you can load them all with module('foo')
      moduleName: 'templates'

    # optionally, configure the Coverage reporter
    coverageReporter:
      type: 'text'
      dir: '../config/coverage'
      file: '' # no filename = display in console
