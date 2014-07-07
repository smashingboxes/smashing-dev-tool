gulp.task 'build:data', (done) ->
  log.tag 'build', 'data'
  compiledFiles('py')
    .pipe $.if isVerbose, $.using()
    .pipe dest.build()
