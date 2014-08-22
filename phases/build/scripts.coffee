lazypipe = require 'lazypipe'

module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, compiledFiles, vendorFiles, copyFiles, time, filters, dest, colors, $, banner} = helpers
  {logger, notify, execute} = util

  cfg =
    ngmin:
      dynamic: true
    uglify:
      mangle: true
      preserveComments: 'some'
    closureCompiler:
      compilerPath: "#{dir.compile}/components/vendor/closure-compiler/compiler.jar"
      fileName: 'dist/SupportAutomation.min.js'
    bowerRequire:
      config: "#{dir.compile}/SupportAutomation.js"
      transitive: true

  ###
  <h2>Scripts<h2>
  ###

  devBanner = lazypipe()
    .pipe $.header, banner

  optimizeScripts = lazypipe()
    .pipe($.stripDebug)
    .pipe($.uglify, cfg.uglify)



  tasks.add 'build:scripts', (done)->
    compiledFiles('js')
      # .pipe($.using())
      .pipe optimizeScripts()
      .pipe dest.build()

    # if args.bundle
    #   # Inject vendor assets into Require config
    #   bowerRequireJS cfg.tasks.bowerRequire, (rjsConfigFromBower) ->
    #     $.requirejs(rconfig)
    #       .pipe optimizeScripts()
    #       .pipe dest.build()
    # else
    #   run 'build:vendor', ->
    #      compiledFiles('js')
    #        .pipe dest.build()
