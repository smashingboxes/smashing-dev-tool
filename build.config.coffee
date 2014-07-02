###
<h1>   Build Configuration   </h1>

Global configuration settings are offloaded to this file
to keep the main Gulpfile clean and succinct.
###
# <br><br><br>
_ =               require 'lodash'
fs =              require 'fs'
path =            require 'path'
join =            path.join
repo =            'https://github.com/Cisco-Systems-SWTG/ApolloSmartTerminal'


clientDir =       'client'
serverDir =       'server'
compileDir =      'compile'
buildDir =        'build'
deployDir =       'deploy'
docsDir =         'docs'


module.exports =
  timestamp:
    dev: 'YYYYMM'
    qa: 'YYYYMMDD.HHmmss'

  clientDir: clientDir
  serverDir: serverDir
  compileDir: compileDir
  buildDir: buildDir
  deployDir: deployDir

  docsDir: docsDir
  openDocs: true
  openDocsUrl: "#{docsDir}/config/gulpfile.html"

  tasks:

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
        {pattern: '**/*.stylus', included: false},
      ]
      exclude: 'components/vendor/*'
    # <br><br><br>



    ###
    **[Groc](https://github.com/nevir/groc)**

    Groc takes your documented code and generates documentation that follows
    the spirit of literate programming. This ensures documentation is always
    up-to-date and in sync with the source code.
    ###
    groc:
      'glob': [
        "#{clientDir}/**/*.coffee"
        "#{clientDir}/**/*.jade"
        "#{clientDir}/**/*.js"
        "config/**/*.coffee"
        "README.md"
      ]
      'except': [
        "#{clientDir}/components/vendor/**/*"
        "config/plugins/**/*"
      ]
      'github':           false
      'out':              'docs'
      'repository-url':   'http://github.com/Cisco-Systems-SWTG/ApolloSmartTerminal'
      'silent':           true
    # <br><br><br>



    ###
    **<h5>[gulp-exec](https://github.com/robrich/gulp-exec)</h5>**

    A Gulp wrapper for child_process.exec(). Execute shell commands.
    ###
    exec:
      continueOnError: true
      pipeStdout: false

    execReport:
      err: true
      stderr: true
      stdout: true
    # <br><br><br>


    ###
    **<h5>[gulp-csso](https://github.com/ben-eb/gulp-csso)</h5>**

    CSSO (CSS Optimizer) is a CSS minimizer unlike others. In addition
    to usual minification techniques it can perform structural optimization
    of CSS files, resulting in smaller file size compared to other minifiers.
    See more detailed information [here](http://ru.bem.info/tools/optimizers/csso/)
    ###
    csso: false # set to true to prevent structural modifications
    # <br><br><br>


    ###
    **<h5>[gulp-css2js](https://github.com/tests-always-included/gulp-css2js)</h5>**
    <em>Wrapper for <strong><a href="https://github.com/grnadav/css2js">css2js</a></strong></em>

    Convert CSS into a self-executing function that injects a `<style>` element
    into the `<head>` of the document.
    ###
    css2js:
      splitOnNewline: true
      trimSpacesBeforeNewline: true
      trimTrailingNewline: true


    ###
    **<h5>[gulp-myth](https://github.com/sindresorhus/gulp-myth)</h5>**
    <em>Wrapper for <strong><a href="https://github.com/segmentio/myth">Myth</a></strong></em>

    Myth lets you write pure CSS while still giving you the benefits of tools
    like LESS and Sass. You can still use variables and math functions, just
    like you do in preprocessors. It's like a polyfill for future versions of
    the spec.
    ###
    myth:
      sourcemap: false
      # browsers: []
    # <br><br><br>



    ###
    **<h5>[gulp-stylus](https://github.com/stevelacy/gulp-stylus)</h5>**
    <em>Wrapper for <strong><a href="http://learnboost.github.io/stylus/">Stylus</a></strong></em>

    Stylus is a css preprocessor and syntax. It extends base
    CSS capabilities, similar to SASS or LESS.
    ###
    stylus:
      errors: true
    # <br><br><br>



    ###
    **<h5>[gulp-rimraf](https://github.com/robrich/gulp-rimraf)</h5>**

    Remove files witl `rm -rf`
    ###
    rimraf:
      force: true
      read: false
    # <br><br><br>



    ###
    **<h5>[gulp-coffee](https://github.com/wearefractal/gulp-coffee)</h5>**

    Compile Coffeescript files
    ###
    coffee:
      bare: true



    ###
    **<h5>[gulp-ngmin](https://github.com/sindresorhus/gulp-ngmin)</h5>**
    <em>Wrapper for <strong><a href="https://github.com/btford/ngmin">ngmin</a></strong></em>
    ###
    ngmin:
      dynamic: true
    # <br><br><br>


    ###
    **<h5>[gulp-uglify](https://github.com/terinjokes/gulp-uglify)</h5>**
    <em>Wrapper for <strong><a href="https://github.com/mishoo/UglifyJS2">UglifyJS2</a></strong></em>

    Minify/compress/mangle Javascript in for deployment.
    ###
    uglify:
      mangle: true
      preserveComments: 'some'
    # <br><br><br>


    ###
    **<h5>[gulp-closure-compile](https://github.com/steida/gulp-closure-compiler)</h5>**
    <em>Wrapper for Google's <strong><a href="https://developers.google.com/closure/compiler/">Closure Compiler</a></strong></em>

    Optimize javascript to download and run faster.
    ###
    closureCompiler:
      compilerPath: 'client/components/vendor/closure-compiler/compiler.jar'
      fileName: 'dist/SupportAutomation.min.js'
    # <br><br><br>


    ###
    **<h5>[bower-requirejs](https://github.com/yeoman/bower-requirejs)</h5>**

    Automagically wire-up installed Bower components into your RequireJS config
    ###
    bowerRequire:
      config: "#{compileDir}/SupportAutomation.js"
      transitive: true
    # <br><br><br>


    ###
    **<h5>[gulp-ng-html2js](https://github.com/marklagendijk/gulp-ng-html2js)</h5>**

    Generates AngularJS modules which pre-load your HTML code into the $templateCache.
    ###
    ngHtml2js:
      moduleName: "views"
      prefix: ''
    # <br><br><br>



    ###
    [imacss](https://github.com/akoenig/imacss) is an application and library that transforms image
    files to [data URIs (rfc2397)](http://www.ietf.org/rfc/rfc2397.txt)
    and embeds them into a single CSS file as background images.
    ###
    imacss: 'images.css'

    imagemin:
      progressive: true


    ###
    <h2>Linting</h2>

    A lint tool performs static analysis of source code and flags
    patterns that might be errors or otherwise cause problems for
    the developer.
    ###

    ###
    **[CSSLint](https://github.com/CSSLint/csslint)**
    ###
    csslint:
      'adjoining-classes':            false
      'box-model':                    false
      'compatible-vendor-prefixes':   false
      'duplicate-background-images':  false
      'import':                       false
      'important':                    false
      'outline-none':                 false
      'overqualified-elements':       false
      'text-indent':                  false
    # <br><br><br>


    ###
    **[JShint](https://github.com/jshint/jshint/)**
    ###
    jshint:
      # 'camelcase':                    true
      'curly':                        true
      'eqeqeq':                       true
      'eqnull':                       true
      # 'expr':                         true
      # 'latedef':                      true
      # 'onevar':                       true
      # 'noarg':                        true
      # 'node':                         true
      # 'trailing':                     true
      # 'undef':                        true
      # 'unused':                       true
    # <br><br><br>


    ###
    **[HTMLHint](https://github.com/yaniswang/HTMLHint)**
    ###
    htmlhint:
      'tagname-lowercase':            true
      'attr-lowercase':               true
      'attr-value-double-quotes':     true
      'attr-value-not-empty':         true
      'doctype-first':                false
      'tag-pair':                     true
      'tag-self-close':               true
      'spec-char-escape':             true
      'id-unique':                    true
      'head-script-disabled':         true
      'img-alt-require':              true
      'doctype-html5':                true
      'id-class-value':               'dash'
      'style-disabled':               true
    # <br><br><br>


    ###
    **[coffeelint](https://github.com/clutchski/coffeelint)**
    ###
    coffeelint:
      coffeescript_error:
        level: 'error'
      no_tabs:
        name: 'no_tabs'
        level: 'error'
      no_trailing_whitespace:
        name: 'no_trailing_whitespace'
        level: 'warn'
        allowed_in_comments: false
        allowed_in_empty_lines: true
      max_line_length:
        name: 'max_line_length'
        value: 160
        level: 'warn'
        limitComments: true
      no_trailing_semicolons:
        name: 'no_trailing_semicolons'
        level: 'error'
      camel_case_classes:
        name: 'camel_case_classes'
        level: 'error'
      no_throwing_strings:
        name: 'no_throwing_strings'
        level: 'error'
      no_backticks:
        name: 'no_backticks'
        level: 'error'
      duplicate_key:
        name: 'duplicate_key'
        level: 'error'
      cyclomatic_complexity:
        name: 'cyclomatic_complexity'
        value: 10
        level: 'ignore'
      no_unnecessary_fat_arrows:
        name: 'no_unnecessary_fat_arrows'
        level: 'warn'
      missing_fat_arrows:
        name: 'missing_fat_arrows'
        level: 'ignore'
    # <br><br><br>
