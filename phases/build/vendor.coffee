gulp.task 'build:vendor', ->
  log.tag 'build', 'vendor'
  vendorFiles('*')
    .pipe $.if isVerbose, $.using()
    .pipe gulp.dest "#{cfg.buildDir}/components/vendor"
