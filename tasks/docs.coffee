
###
**Gulp plugins** <br>
Import `gulp` and alias `gulp-util`
###
gulp =            require 'gulp'                  # streaming build system
$ =               require('gulp-load-plugins')(camelize: true)  # attach  "gulp-*" plugins to '$' variable
open =            require 'open'
fs =              require 'fs'


cfg =             require '../build.config'
helpers =         require './helpers'

{
  copyFiles
  files
  vendorFiles
  time
  filters
  dest
  colors
  log
  execute
  notify
} = helpers




###
**docs:generate** <br>
Generate documentation using Groc
###
generateDocs = exports.generateDocs = (done) ->
  notify "Groc", "Generating documentation..."

  # Provide realtime output of generated files, rather than at the end
  watcher = gulp.watch(["docs/**/*"]).on 'all', (event) ->
    path = event.path
    path = path.substr(path.indexOf cfg.docsDir)
    log colors.green "    ✔    #{path} "

  # Dynamically generate .groc.json from config
  fs.writeFile '.groc.json', JSON.stringify(cfg.tasks.groc), 'utf8', ->
    log colors.green 'Generated .groc.json from config'
    execute 'groc', ->
      watcher.end()
      notify "Groc", "Success!"
      open cfg.openDocsUrl  if cfg.openDocs
      done()


###
**docs:clean** <br>
Remove previously generated documentation
###
gulp.task 'docs:clean', (cb) ->
  gulp.src cfg.docsDir
   .pipe $.rimraf(cfg.tasks.rimraf)

# <br><br><br>
