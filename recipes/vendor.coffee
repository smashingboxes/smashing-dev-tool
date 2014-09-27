through2       = require 'through2'
gulp           = require 'gulp'
bowerRequireJS = require 'bower-requirejs'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, mainFile, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers

  # bowerRequire =
  #   config: "#{env.configBase}/#{dir.compile}/main.js"
  #   transitive: true


  ### ---------------- TASKS ---------------------------------------------- ###
  tasks.add 'compile:vendor', ->
    # synchro = (done) ->
    #   through2.obj(
    #     ((data, enc, cb)-> cb()),
    #     (cb) ->
    #       cb()
    #       done()
    #   )

    vendorFiles('*')
      .pipe $.if args.verbose, $.using()
      .pipe $.size title:'vendor'
      .pipe gulp.dest "#{dir.compile}/components/vendor"
      # .pipe synchro done
