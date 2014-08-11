{files, vendorFiles, dest, banner, $, lazypipe} = require('../../config/helpers')
{logger, notify, execute} = require('../../config/util')
{assets, tasks, args, dir, pkg} = require('../../config/config')

gulp = require 'gulp'

tasks.add 'compile:vendor', ->
  vendorFiles('*')
    .pipe($.using())
    .pipe(gulp.dest "#{dir.compile}/components/vendor")
