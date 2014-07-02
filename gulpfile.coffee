###
<h1>  Build System  </h1>
<strong>Powered by <a href="http://gulpjs.com/" target="_blank">Gulp</a></strong>

Gulp is a JavaScript build system that utilizes streams to transform project
assets without creating temporary files. Files are piped into a task, transformed
and piped out to the next task or written to the disk.
<br><br><br>
###

run =             require 'run-sequence'          # execute tasks in parallel or series
gulp =            require 'gulp'                  # streaming build system
cached =          require 'gulp-cached'
watch =           require 'gulp-watch'

{
  STACKATO_APP_ID
  APP_NAME
  APP_VERSION
  APP_VERSION_AS_URL
  log
  colors
  isQa
  isVerbose
  isBundled
  isOptimized
  base64Images
  isWatching
} = require './tasks/helpers'                     # import helpers
# <br><br><br>



###
<h2>   Workflow   </h2><br>

Because of it's complexity this build has been divided into
several phases with corresponding external configuration located in `config/tasks/`.
Utility functions and constants used across tasks are located in `config/tasks/helpers`
###


###
**gulp**  <br>
Running `gulp` will execute the 'default' task, which compiles and builds the app, placing
the result in `deploy/`. This will not deploy the app.

*[--verbose]*  <br> log file paths to console as they are processed <br><br>
*[--qa]*       <br> build app for QA deployment
###

logHeader = "================  #{APP_NAME}  ================"
qaHeader = "Performing QA build"

appNameLength = (char) ->
  str = ""
  str += char for [1..logHeader.length]
  str
qaNameLength = (char) ->
  str = ""
  str += "▓" for [2..(logHeader.length - qaHeader.length)/2]
  str

log colors.red.bgRed          "#{appNameLength('▓')}"  if isQa
log   colors.red.bgRed "#{qaNameLength()}", colors.bgRed.white "Performing QA build", colors.red.bgRed "#{qaNameLength()}"  if isQa
log colors.red.bgRed          "#{appNameLength('▓')}"  if isQa
log colors.bold          logHeader
log colors.cyan          "Version: #{APP_VERSION}"
log colors.cyan          "Version (URL): #{APP_VERSION_AS_URL}"
log.alt isVerbose,       "Verbose Mode:       "
log.alt isWatching,      "Watch For Changes:  "
log colors.bold          "#{appNameLength('=')}"
log colors.red.bgRed          "#{appNameLength('▓')}"  if isQa


gulp.task 'default', (done) ->
  # watcher.on 'change',
  run 'compile', 'build', 'war', done
# <br><br><br>




###
<h4><strong>   Static Assets   </strong></h4>

Static assets such as CoffeeScript and Jade must be compiled before they
can be interpreted by the browser. Some assets need to be validated/linted
and compressed, while others can be copied directly to the server. These
tasks define transformations for each asset type to incorporate it into
the final build.
###
build = require './tasks/build'


###
**clean**  <br>
Running `gulp clean` will remove all generated code from the project directory.

*[--verbose]*  <br> log file paths to console as they are processed <br><br>
###
gulp.task 'clean', (done) ->
  run ['clean:compile', 'clean:build', 'clean:deploy', 'docs:clean'], done
# <br><br>


###
**compile**  <br>
Running `gulp compile` will process all source code in `client/` and copy it
to `compile/`, mirroring the directory structure and linting and compiling where
applicable. Compiled code should contain comments and generally be optimized
for human readability. Compiled code should consist only of file formats that
will be sent directly to the browser (i.e. no `.coffee`, `.scss`, etc.).

*[--verbose]*  <br> log file paths to console as they are processed <br><br>
*[--watch]*    <br> listen for changes to source code and recompile individual files <br><br>
*[--test]*     <br> run tests after compiling files <br><br>
*[--sync]*     <br> upload individual watched files via `stackato scp` <br><br>
###
gulp.task 'compile', (done) ->
  run 'clean:compile', 'compile:all', done
# <br><br>


###
**build**  <br>
Running `gulp build` will process compiled code in `compiled/` and prepare it
for production deployment. This includes optimization, minifcation, compression,
and bundling of assest. This build is configured to convert HTML, CSS files to
JavaScript and bundle them together.

*[--verbose]*  <br> log file paths to console as they are processed <br><br>
###
gulp.task 'build', (done) ->
  run 'clean:build', 'build:all', done
# <br><br>






###
<h4><strong>   Deploying   </strong></h4>
###
deploy = require './tasks/deploy'
scp = require './plugins/gulp-stackato-sync'
###
**deploy**  <br>
Running `gulp deploy` will combine optimized client-side code with server-side
code and deploy it to the appropriate remote enviornment.

*[--verbose]*  <br> log file paths to console as they are processed <br><br>
###
gulp.task 'deploy', (done) ->   run 'war', done
gulp.task 'update', (done) ->   run 'stackato:update', done
gulp.task 'push', (done) ->     run 'stackato:push', done

gulp.task 'sync', (done) ->
  watch(glob: 'compile/**/*.*')
    .pipe scp STACKATO_APP_ID, APP_NAME
# <br><br><br>







###
<h4><strong>   Testing   </strong></h4>
###
test = require './tasks/test'

###
**test**  <br>
Running `gulp test` will run all tests for this application and generate a
code coverage report.

*[--verbose]*  <br> log file paths to console as they are processed <br><br>
###
gulp.task 'test', test.runAll
# <br><br><br>






###
<h4><strong>   Documentation Generation   </strong></h4>
###
docs = require './tasks/docs'

###
**docs**  <br>
Running `gulp docs` will parse source code for comments with Groc and generate a static
documentation site at `docs/` using the app `README.md` as the index.

*[--verbose]*  <br> log file paths to console as they are processed <br><br>
###
gulp.task 'docs', docs.generateDocs
# <br><br><br>
