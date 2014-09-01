#!/usr/bin/env coffee


{logger, notify, execute} = require './util'
{assets, tasks, args, dir, pkg, env} = require('./config')

_ =               require 'underscore'                # array and object utilities
chalk =           require 'chalk'

tildify =         require 'tildify'
moment =          require 'moment'                # time/date utils
open =            require 'open'                  # open files
fs =              require 'fs'
path =            require 'path'                  # manipulate file paths
join =            path.join


through =         require 'through2'
lazypipe =        require 'lazypipe'              # re-use partial streams
runSequence =     require 'run-sequence'          # execute tasks in parallel or series
combine =         require 'stream-combiner'

smashPkg =        require '../package'
smashRoot =       process.mainModule.filename.replace '/bin/smash', ''

gulp =            require 'gulp'                  # streaming build system
$ = exports.$ =   require('gulp-load-plugins')(camelize: true, config: smashPkg)  # attach  "gulp-*" plugins to '$' variable
$.util =          require 'gulp-util'

{colors} =        $.util
exports.colors =  colors
exports.lazypipe = lazypipe
# <br><br><br>


# central config object included/modified by other components
# config = exports.config =
#   tasks:
#     ###
#     **<h5>[gulp-exec](https://github.com/robrich/gulp-exec)</h5>**
#
#     A Gulp wrapper for child_process.exec(). Execute shell commands.
#     ###
#     exec:
#       continueOnError: true
#       pipeStdout: false
#
#     execReport:
#       err: true
#       stderr: true
#       stdout: true
#
#
#     ###
#     **<h5>[gulp-rimraf](https://github.com/robrich/gulp-rimraf)</h5>**
#
#     Remove files witl `rm -rf`
#     ###
#     rimraf:
#       force: true
#       read: false

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
exports.files = (types...) ->
  console.log 'getting files for ' + types.join ', '
  # Ignore vendor files and tests
  source = [
    "!#{dir.client}/components/vendor/**/*"
    "!**/*_test.*"
  ]

  for type in types
    source.push "#{dir.client}/**/*.#{type}"

  # We can attach any tasks that should be run on all files here.
  # In this case, we add a reference to the global file cache to
  # enable incremental builds.
  if args.watch
    gulp.src(source, cwd: env.configBase )
      .pipe $.cached('main')
      .pipe $.watch()
      .pipe $.plumber()
  else
    gulp.src(source)
      .pipe $.cached('main')





###
Returns a source pipe containing assets from `bower_components`,
optionally filtered to a specific file type.
@method vendorFiles
@param {...String} types The desired file types
@return {Object}
###
exports.vendorFiles = (types...) ->
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
exports.compiledFiles = (types...) ->
  # Ignore vendor files
  source = [
    "!#{dir.compile}/components/vendor/**/*",
    # "!#{dir.compile}/components/common/**/*"
  ]

  for type in types
    source.push "#{dir.compile}/**/*.#{type}"

  if args.watch
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
exports.dest =
  compile: -> gulp.dest dir.compile
  build: -> gulp.dest dir.build
  deploy: -> gulp.dest dir.deploy
  client: -> gulp.dest dir.client
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
banner = exports.banner =  "/** \n
           * APP_NAME
           */ \n\n"
