###
**<h5>[gulp-stylus](https://github.com/stevelacy/gulp-stylus)</h5>**
<em>Wrapper for <strong><a href="http://learnboost.github.io/stylus/">Stylus</a></strong></em>

Stylus is a css preprocessor and syntax. It extends base
CSS capabilities, similar to SASS or LESS.
###
stylus:
  errors: true
# <br><br><br>



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
