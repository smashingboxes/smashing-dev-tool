
###
**<h5>[gulp-coffee](https://github.com/wearefractal/gulp-coffee)</h5>**

Compile Coffeescript files
###
coffee:
  bare: true


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
