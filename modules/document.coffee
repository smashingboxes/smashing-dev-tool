fs =              require 'fs'
open =            require 'open'
gulp =            require 'gulp'                  # streaming build system
_ =               require 'underscore'


module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, compiledFiles, vendorFiles, copyFiles, time, filters, dest, colors, $, banner} = helpers
  {logger, notify, execute} = util

  ###
  **[Groc](https://github.com/nevir/groc)**

  Groc takes your documented code and generates documentation that follows
  the spirit of literate programming. This ensures documentation is always
  up-to-date and in sync with the source code.
  ###
  docsGlob = [
    "#{env.configBase}/README.md"
  ]
  for key, val of assets
    docsGlob.push "#{env.configBase}/#{dir.client}/**/*.#{val.ext}" if val.doc


  groc =
    'glob': docsGlob
    'except': [
      "#{env.configBase}/#{dir.client}/components/vendor/**/*"
    ]
    'github':           false
    'out':              dir.docs
    'repository-url':   pkg.repository?.url or ''
    'silent':           !args.verbose?

  rimraf =
    force: true
    read: false

  tasks.add 'docs', (done) ->
    notify "Groc", "Generating documentation..."

    # Dynamically generate .groc.json from config
    fs.writeFile "#{env.configBase}/.groc.json", JSON.stringify(groc), 'utf8', ->
      logger.info  colors.green 'Generated .groc.json from config'

      # Use our copy of Groc to generate documentation for the project
      require("#{env.configBase}/node_modules/fe_build/node_modules/groc").CLI [], (error)->
        process.exit(1) if error
        notify "Groc", "Success!"
        open "#{env.configBase}/docs/index.html"
        done()

  tasks.add 'docs:clean', (cb) ->
    gulp.src dir.docs
     .pipe $.rimraf rimraf

  commander
    .command('docs')
    .description('Generate documentation based on source code')
    .action ->
      tasks.start 'docs'
