fs =              require 'fs'
open =            require 'open'
gulp =            require 'gulp'                  # streaming build system
_ =               require 'underscore'
chalk =           require 'chalk'
del =             require 'del'


module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util
  {assets, env, dir, pkg, helpers} = getProject()
  {files, $} = helpers

  ### ---------------- COMMANDS ------------------------------------------- ###
  commander
    .command('docs')
    .description('Generate documentation based on source code')
    .action ->
      tasks.start 'docs'


  ### ---------------- TASKS ---------------------------------------------- ###
  tasks.add 'docs', (done) ->
    # notify "Groc", "Generating documentation..."
    logger.info "Generating documentation in #{chalk.magenta './'+dir.docs}"

    docsGlob = ["README.md"]
    for key, val of assets
      if val.doc
        docsGlob.push "#{dir.client}/**/*.#{val.ext}"
        docsGlob.push "#{dir.server}**.*.#{val.ext}"

    grocjson = JSON.stringify {
      'glob': docsGlob
      'except': [
        "#{dir.client}/components/vendor/**/*"
      ]
      'github':           false
      'out':              dir.docs
      'repository-url':   smash.pkg.repository?.url or ''
      'silent':           !args.verbose?
    }, null, 2

    # Dynamically generate .groc.json from config
    fs.writeFile "#{env.configBase}/.groc.json", grocjson, 'utf8', ->
      logger.info "Generated dynamic #{chalk.green '.groc.json'} from project config"  if args.verbose

      # Use our copy of Groc to generate documentation for the project
      require("#{smash.root}/node_modules/groc").CLI [], (error)->
        process.exit(1) if error
        # notify "Groc", "Success!"
        open "#{dir.docs}/index.html"
        done()

  tasks.add 'docs:clean', (done) ->
    if fs.existsSync dir.docs
      logger.info "Deleting #{chalk.magenta './'+dir.docs}"
      del [dir.docs], done
    else
      done()
