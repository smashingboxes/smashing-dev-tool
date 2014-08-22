fs =              require 'fs'
open =            require 'open'
gulp =            require 'gulp'                  # streaming build system


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
  console.log env.configBase
  groc =
    'glob': [
      "#{env.configBase}/#{dir.client}/**/*.coffee"
      "#{env.configBase}/#{dir.client}/**/*.jade"
      "#{env.configBase}/#{dir.client}/**/*.js"
      "#{env.configBase}/config/**/*.coffee"
      "#{env.configBase}/README.md"
    ]
    'except': [
      "#{env.configBase}/#{dir.client}/components/vendor/**/*"
      "#{env.configBase}/config/plugins/**/*"
    ]
    'github':           false
    'out':              'docs'
    'repository-url':   'http://github.com/Cisco-Systems-SWTG/ApolloSmartTerminal'
    'silent':           true


  rimraf =
    force: true
    read: false



  tasks.add 'docs', (done) ->
    # notify "Groc", "Generating documentation..."

    # Provide realtime output of generated files, rather than at the end
    watcher = gulp.watch(["#{env.configBase}/docs/**/*"]).on 'all', (event) ->
      path = event.path
      path = path.substr(path.indexOf dir.docs)
      log colors.green "    ✔    #{path} "

    # Dynamically generate .groc.json from config
    fs.writeFile "#{env.configBase}/.groc.json", JSON.stringify(groc), 'utf8', ->
      logger.info  colors.green 'Generated .groc.json from config'
      execute ".#{process.cwd()}/node_modules/fe_build/node_modules/groc/bin/groc", (back)->
        console.log back
        watcher.end()
        notify "Groc", "Success!"
        # open cfg.openDocsUrl
        done()

  tasks.add 'docs:clean', (cb) ->
    gulp.src dir.docs
     .pipe $.rimraf rimraf





  commander
    .command('docs')
    .description('Generate documentation based on source code')
    .action ->
      tasks.start 'docs'
