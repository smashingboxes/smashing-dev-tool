jsStylish = require 'jshint-stylish'
jshintrc = require '../../config/lint/jshintrc'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  tasks.add 'compile:js', ->
    {assets, env, dir, pkg, helpers} = getProject()
    {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers

    files('js')
      .pipe($.using())
      .pipe($.jshint jshintrc)
      .pipe($.jshint.reporter jsStylish)
      .pipe dest.compile()
