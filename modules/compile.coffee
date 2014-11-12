required       = require 'require-dir'
gulp           = require 'gulp'
lazypipe       = require 'lazypipe'
_              = require 'underscore'
merge          = require 'merge-stream'
amdOptimize    = require 'amd-optimize'
bowerRequireJS = require 'bower-requirejs'
del            = require 'del'

module.exports = (globalConfig) ->
  {args, util, tasks, fileRecipes, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util
  {assets, helpers, dir, env} = getProject()
  {vendorFiles, mainFile, compiledFiles, files, dest, $} = helpers

  recipes = {}
  for recipe in ['coffee', 'js', 'styl', 'css', 'jade', 'html', 'json', 'vendor']
    recipes[recipe] = require("../recipes/#{recipe}")(globalConfig)




  ### ---------------- COMMANDS ------------------------------------------- ###
  commander
    .command('compile')
    .alias('c')
    .option('-w, --watch', 'Watch files and recompile on change')
    .option '-r --reload', 'Reload the browser on change'
    .description('compile local assets based on Smashfile')
    .action ->
      # tasks.start 'compile'
      tasks.start 'compile:inject:index'



  ### ---------------- TASKS ---------------------------------------------- ###
  tasks.add 'compile', ['compile:clean'], (done) ->
    assetTasks = ("compile:#{ext}" for ext, asset of assets)
    tasks.start assetTasks.concat(['compile:vendor']), done



  # tasks.add 'compile:assets', assetTasks.concat(['compile:vendor']), (done) ->
    # tasks.start 'compile:inject:deps', done
    tasks.start 'compile:inject:index', done


  # Inject asset paths into index.html for development
  injectIndex = ->
    files path: "#{dir.client}/index.jade"
      .pipe $.if args.verbose, $.using()

      # inject CSS
      .pipe $.inject files('compile', ['.css'], false),
        name: 'app'
        ignorePath: 'compile'
        addRootSlash: false

      # inject JS (Angular)
      .pipe $.inject files('compile', ['.js'], false).pipe($.angularFilesort()),
        name:'app'
        ignorePath: 'compile'
        addRootSlash: false

      # inject vendor files
      .pipe $.inject files('vendor', '*', false),
        name:'vendor'
        ignorePath: 'client'
        addRootSlash: false

      .pipe $.if args.verbose, $.cat()
      .pipe $.jade pretty:true, compileDebug:true
      .on('error', (err) -> logger.error err.message)
      .pipe dest.compile()

  tasks.add 'compile:inject:index', (done)->
    if args.watch
      gulp.task 'inject:index', injectIndex
      gulp.watch "#{dir.client}/index.jade", ['inject:index', $.reload]

    injectIndex()
    done()



  # Ensure the RequireJS file is primed with Bower components
  injectDeps = ->
    files 'vendor'
      .pipe $.using()
      # files path: "#{dir.client}/main.coffee"
      # .pipe $.using()
      # .pipe $.injec(files('vendor', '.js', false)
      #   starttag: '# -- paths:vendor --',
      #   endtag: '# -- endinject --',
      #   ignorePath: 'client',
      #   addRootSlash: false,
      #   transform: (filepath, file, i, length) -> '"' + filepath + '"' + (if i + 1 < length then ',' else '')
      # )
      # .pipe $.cat()
      # .pipe $.coffee bare:true
      # .pipe dest.compile()

  tasks.add 'compile:inject:deps', ->
    files 'vendor', '.js'
      .pipe $.if args.verbose, $.using()
    # files 'compile'
      # .pipe dest.compile()

    # if args.watch
    #   gulp.task 'compile:require', injectDeps
    #   gulp.watch "#{dir.compile}/main.js", ['compile:require', $.reload]
    #
    # injectDeps()
    # done()

    # files path: "#{dir.client}/main.coffee"
    #   .pipe $.coffee()
    #   .pipe $.if args.verbose, $.using()
    #   .pipe $.size title:'require-main'
    #   .pipe dest.compile()
    #   .pipe $.if args.reload, $.reload stream:true


  # Remove previous compilation
  tasks.add 'compile:clean', (done) ->
    del [dir.compile], done
