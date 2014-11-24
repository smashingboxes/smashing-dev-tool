module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, banner, dest, time, $, logging, watching} = helpers

  htmlhintrc = require '../config/lint/htmlhintrc'

  cfg =
    ngHtml2js:
      moduleName: "views"
      prefix: ''

  ### ---------------- RECIPE --------------------------------------------- ###
  compile = (stream) ->
    stream
      .pipe $.if args.watch, $.cached 'main'
      
      # Lint
      .pipe $.htmlhint htmlhintrc
      .pipe $.htmlhint.reporter()

  build = (stream) ->
    stream
      # Optimize
      .pipe $.htmlmin collapseWhitespace: true

      # Concat
      .pipe $.ngHtml2js cfg.ngHtml2js
      .pipe $.concat 'app-views.js'
      .pipe $.wrapAmd()


  ### ---------------- TASKS ---------------------------------------------- ###
  html =
    compile: ->
      compile files '.html'
        .pipe logging()
        .pipe dest.compile()
        # .pipe watching()

    build: ->
      build files 'compile', '.html'
        .pipe logging()
        .pipe dest.build()
        # .pipe watching()
