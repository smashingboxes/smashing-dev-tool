###
<h2>Data</h2>
###
gulp.task 'compile:data', (done) ->
  log.tag 'compile', 'data'
  files('py')
    .pipe $.if isVerbose, $.using()
    .pipe dest.compile()
