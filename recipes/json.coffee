module.exports = (globalConfig) ->

  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, vendorFiles, compiledFiles,  banner, dest, time, $} = helpers


  ### ---------------- TASKS ---------------------------------------------- ###
  tasks.add 'compile:json', ->
    recipe files '.json'
      .lint()
      .pipe $.if args.verbose, $.using()
      .pipe $.size title:'json'
      .pipe $.if args.reload, $.reload stream:true


  ### ---------------- RECIPE ----------------------------------------------- ###
  recipe = (stream) ->
    stream.lint = ->
      @
        .pipe $.jsonlint()
        .pipe $.jsonlint.reporter()
      @
    stream
