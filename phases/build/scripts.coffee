lazypipe = require 'lazypipe'

module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  tasks.add 'build:scripts', (done)->
    {assets, env, dir, pkg, helpers} = getProject()
    {files, vendorFiles, compiledFiles, copyFiles, banner, dest, time, $} = helpers

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


    devBanner = lazypipe()
      .pipe $.header, banner

    optimizeScripts = lazypipe()
      .pipe($.stripDebug)
      .pipe($.uglify, cfg.uglify)


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
