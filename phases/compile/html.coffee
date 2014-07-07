

gulp.task 'compile:html', ->
  log.tag 'compile', 'html'
  files('html')
    .pipe $.if isVerbose, $.using()
    .pipe $.htmlhint cfg.tasks.htmlhint
    .pipe $.htmlhint.reporter()
    # .pipe $.if isVerbose, $.size title: 'html'
    .pipe dest.compile()
