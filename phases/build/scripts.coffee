
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
