

gulp.task 'compile:js', ->
  log.tag 'compile', 'js'
  files('js')
    .pipe $.if isVerbose, $.using()
    .pipe $.jshint cfg.tasks.jshint
    .pipe $.jshint.reporter jsStylish
    .pipe postProcessScripts()
    # .pipe $.if isVerbose, $.size title: 'javascript'
    .pipe dest.compile()
