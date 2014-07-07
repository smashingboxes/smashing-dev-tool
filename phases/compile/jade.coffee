
gulp.task 'compile:jade', ->
  log.tag 'compile', 'jade'
  files('jade')
    .pipe $.if isVerbose, $.using()
    .pipe $.jade()
    # .pipe $.if isVerbose, $.size title: 'jade'
    .pipe dest.compile()
