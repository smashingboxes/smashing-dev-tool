
gulp.task 'compile:json', ->
  log.tag 'compile', 'json'
  files('json')
    .pipe $.if isVerbose, $.using()
    .pipe $.jsonlint()
    .pipe $.jsonlint.reporter()
    # .pipe $.if isVerbose, $.size title: 'json'
    .pipe dest.compile()
