###
<h2>Helpers</h2>

Here we define some general helper functions to be used throughout the
build. By creating some stream factory functions we can minimize repitition
in our source code and make our Gulp tasks more human-readable.
###


###
**General modules** <br>
General-purpose Node modules and libraries.
###
_ =               require 'lodash'                # array and object utilities
open =            require 'open'                  # open files
fs =              require 'fs'
path =            require 'path'                  # manipulate file paths
join =            path.join
exec =            require('child_process').exec   # execute commands
moment =          require 'moment'                # time/date utils
args =            require('yargs').argv           # utilize command line args
notifier =        require('node-notifier')
through =         require 'through2'

lazypipe =        require 'lazypipe'              # re-use partial streams
combine =         require 'stream-combiner'
runSequence =     require 'run-sequence'          # execute tasks in parallel or series

gulp =            require 'gulp'                  # streaming build system
$ =               require('gulp-load-plugins')(camelize: true)  # attach  "gulp-*" plugins to '$' variable
$.util =          require 'gulp-util'

{colors} =        $.util
exports.colors =  colors
# <br><br><br>





###
**<h5>[gulp-exec](https://github.com/robrich/gulp-exec)</h5>**

A Gulp wrapper for child_process.exec(). Execute shell commands.
###
exec:
  continueOnError: true
  pipeStdout: false

execReport:
  err: true
  stderr: true
  stdout: true
# <br><br><br>



###
**<h5>[gulp-rimraf](https://github.com/robrich/gulp-rimraf)</h5>**

Remove files witl `rm -rf`
###
rimraf:
  force: true
  read: false
# <br><br><br>



# Initalize internal flags from commandline args
isQa =           exports.isQa =            args.qa?
isVerbose =      exports.isVerbose =       args.verbose?
isBundled =      exports.isBundled =       args.bundle?
isOptimized =    exports.isOptimized =     args.optimize?
isBase64 =       exports.isBase64 =        args.base64img?
isWatching =     exports.isWatching =      args.watch?
isSyncing =      exports.isSyncing =       args.sync?

isCompiling =    exports.compileMode =     args.compile?
isBuilding =     exports.buildMode =       args.build?

isDocumenting =  exports.docMode =         args.docs?
# <br><br><br>


# Load external configuration
cfg =             require '../build.config'
rconfig =         require '../build.require'

# Determine current working directory
base =            require.main.filename
currentDir = exports.currentDir = base.replace base.substr(base.indexOf 'node_modules'), ''



###
Returns a source pipe for a given asset type. This gives us
a place to attach plugins that should be used for all asset groups
and allows us to use a much cleaner syntax when building tasks.
@method files
@param {...String} types The desired file types
@return {Object}
###
files = exports.files = (types...) ->
  # Ignore vendor files and tests
  source = [
    "!#{cfg.clientDir}/components/vendor/**/*"
    "!**/*_test.*"
  ]

  for type in types
    source.push "#{cfg.clientDir}/**/*.#{type}"

  # We can attach any tasks that should be run on all files here.
  # In this case, we add a reference to the global file cache to
  # enable incremental builds.
  if isWatching
    gulp.src(source)
      .pipe $.cached('main')
      .pipe $.watch()
      .pipe $.plumber()
  else
    gulp.src(source)
      .pipe $.cached('main')
# <br><br><br>




###
Returns a source pipe containing assets from `bower_components`,
optionally filtered to a specific file type.
@method vendorFiles
@param {...String} types The desired file types
@return {Object}
###
vendorFiles = exports.vendorFiles = (types...) ->
  source = []
  for type in types
    source.push "**/*.#{type}"

  $.bowerFiles()
    .pipe $.filter source
# <br><br><br>



###
Returns a source pipe containing assets from `bower_components`,
optionally filtered to a specific file type.
@method vendorFiles
@param {...String} types The desired file types
@return {Object}
###
compiledFiles = exports.compiledFiles = (types...) ->
  # Ignore vendor files
  source = [
    "!#{cfg.compileDir}/components/vendor/**/*",
    # "!#{cfg.compileDir}/components/common/**/*"
  ]

  for type in types
    source.push "#{cfg.compileDir}/**/*.#{type}"

  if isWatching
    gulp.src(source)
      .pipe $.cached('main')
      .pipe $.watch()
      .pipe $.plumber()
  else
    gulp.src(source)
# <br><br><br>



###
Copy files from source to destination
@method copyFiles
@param {Object} files A group of files to copy
###
exports.copyFiles = (files) ->
  for file in files
    log "Copying #{file.src} to #{file.dest}"  if isVerbose

    if typeof file.src is 'string'
      source = [file.src]
    else
      source = file.src

    if file.replace?
      gulp.src(source)
        .pipe $.if isVerbose, $.using()
        .pipe($.replace file.replace[0], file.replace[1])
        .pipe(gulp.dest file.dest)
    else
      gulp.src(source)
        .pipe(gulp.dest file.dest)
# <br><br><br>



###
Returns a destination pipe for the build directory
@method dest
###
dest = exports.dest =
  compile: -> gulp.dest cfg.compileDir
  build: -> gulp.dest cfg.buildDir
  deploy: -> gulp.dest cfg.deployDir
# <br><br><br>



###
Returns the current time with the given format
@method time
@param {String} format moment.js time format
@return {Object}
###
time = exports.time = (f) ->
  moment().format(f)
# <br><br><br>


# Banner placed at the top of all JS files during development
exports.banner =  "/** \n
           * #{APP_NAME} - #{time(cfg.timestamp.dev)} \n
           * @version v#{APP_VERSION} \n
           * @link #{APP_VERSION_AS_URL} \n
           */ \n\n"
