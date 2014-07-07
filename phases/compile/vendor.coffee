
###
<h2>Vendor</h2>
###
gulp.task 'compile:vendor', ->
  log.tag 'compile', 'vendor'
  vendorFiles('*')
    .pipe $.if isVerbose, $.using()
    .pipe gulp.dest "#{cfg.compileDir}/components/vendor"
