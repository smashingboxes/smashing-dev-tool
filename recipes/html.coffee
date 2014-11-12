module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, vendorFiles, compiledFiles,  banner, dest, time, $} = helpers

  cfg =
    ngHtml2js:
      moduleName: "views"
      prefix: ''


  ### ---------------- TASKS ---------------------------------------------- ###
  tasks.add 'compile:html', ->
    recipe files '.html'
      .lint()
      .pipe $.if args.verbose, $.using()
      .pipe $.size title:'html'
      .pipe dest.compile()
      .pipe $.if args.reload, $.reload stream:true

  tasks.add 'build:html', ->
    recipe files 'compile', '.html'
      .optimize()
      .concat()
      .pipe $.if args.verbose, $.using()
      .pipe $.size title:'html'
      .pipe dest.build()

  ### ---------------- RECIPE --------------------------------------------- ###
  recipe = (stream) ->
    stream.lint = ->
      logger.verbose 'linting html'
      htmlhintrc = require '../config/lint/htmlhintrc'
      @
        .pipe $.htmlhint htmlhintrc
        .pipe $.htmlhint.reporter()
      @

    stream.concat = ->
      logger.verbose 'concat html'
      @
        .pipe $.ngHtml2js cfg.ngHtml2js
        .pipe $.concat 'app-views.js'
        .pipe $.wrapAmd()
      @

    stream.optimize = ->
      logger.verbose 'optimizing html'
      @
        .pipe $.htmlmin collapseWhitespace: true
      @
    stream
