


gulp.task 'compile:css', ->
  log.tag 'compile', 'css'
  files('css')
    .pipe $.if isVerbose, $.using()
    .pipe $.csslint cfg.tasks.csslint
    .pipe $.csslint.reporter()
    .pipe postProcessStyles()
    # .pipe $.if isVerbose, $.size title: 'css'
    .pipe dest.compile()
