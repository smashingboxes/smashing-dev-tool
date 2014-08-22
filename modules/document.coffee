fs =              require 'fs'
open =            require 'open'
gulp =            require 'gulp'                  # streaming build system


module.exports = ({assets, tasks, args, dir, env, pkg, util, helpers, commander}) ->
  {files, vendorFiles, copyFiles, time, filters, dest, colors} = helpers
  {logger, notify, execute, $} = util

  ###
  **[Groc](https://github.com/nevir/groc)**

  Groc takes your documented code and generates documentation that follows
  the spirit of literate programming. This ensures documentation is always
  up-to-date and in sync with the source code.
  ###
  groc =
    'glob': [
      "#{dir.client}/**/*.coffee"
      "#{dir.client}/**/*.jade"
      "#{dir.client}/**/*.js"
      "config/**/*.coffee"
      "README.md"
    ]
    'except': [
      "#{dir.client}/components/vendor/**/*"
      "config/plugins/**/*"
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
    watcher = gulp.watch(["docs/**/*"]).on 'all', (event) ->
      path = event.path
      path = path.substr(path.indexOf dir.docs)
      log colors.green "    ✔    #{path} "

    # Dynamically generate .groc.json from config
    fs.writeFile '.groc.json', JSON.stringify(groc), 'utf8', ->
      logger.info  colors.green 'Generated .groc.json from config'
      execute 'groc', ->
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
