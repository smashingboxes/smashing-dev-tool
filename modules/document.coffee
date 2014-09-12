fs =              require 'fs'
open =            require 'open'
gulp =            require 'gulp'                  # streaming build system
_ =               require 'underscore'
chalk =           require 'chalk'


module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  ###
  **[Groc](https://github.com/nevir/groc)**

  Groc takes your documented code and generates documentation that follows
  the spirit of literate programming. This ensures documentation is always
  up-to-date and in sync with the source code.
  ###

  rimraf =
    force: true
    read: false

  tasks.add 'docs', (done) ->
    {assets, env, dir, pkg, helpers} = getProject()

    notify "Groc", "Generating documentation..."

    docsGlob = ["README.md"]
    for key, val of assets
      docsGlob.push "#{dir.client}/**/*.#{val.ext}" if val.doc

    grocjson = JSON.stringify
      'glob': docsGlob
      'except': [
        "#{dir.client}/components/vendor/**/*"
      ]
      'github':           false
      'out':              dir.docs
      'repository-url':   pkg.repository?.url or ''
      'silent':           !args.verbose?

    # Dynamically generate .groc.json from config
    fs.writeFile "#{env.configBase}/.groc.json", grocjson, 'utf8', ->
      logger.info  chalk.green 'Generated .groc.json from config'

      # Use our copy of Groc to generate documentation for the project
      require("#{env.configBase}/node_modules/fe_build/node_modules/groc").CLI [], (error)->
        process.exit(1) if error
        notify "Groc", "Success!"
        open "#{dir.docs}/index.html"
        done()

  tasks.add 'docs:clean', (cb) ->
    {assets, env, dir, pkg, helpers} = getProject()
    $ = helpers.$

    gulp.src dir.docs
      .pipe $.using()
      .pipe $.rimraf force:true, read:false

  commander
    .command('docs')
    .description('Generate documentation based on source code')
    .action ->
      tasks.start 'docs'
