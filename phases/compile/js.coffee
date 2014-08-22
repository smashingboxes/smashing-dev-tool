jsStylish = require 'jshint-stylish'
jshintrc = require '../../config/lint/jshintrc'

module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, vendorFiles, copyFiles, time, filters, dest, colors, $} = helpers
  {logger, notify, execute} = util

  tasks.add 'compile:js', ->
    files('js')
      .pipe($.using())
      .pipe($.jshint jshintrc)
      .pipe($.jshint.reporter jsStylish)
      .pipe dest.compile()
