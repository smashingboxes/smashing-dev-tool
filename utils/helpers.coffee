# Project-specific helpers for accessing source code consistiently regardless of project

_ =               require 'underscore'                # array and object utilities
chalk =           require 'chalk'
tildify =         require 'tildify'
moment =          require 'moment'                # time/date utils
open =            require 'open'                  # open files
fs =              require 'fs'
path =            require 'path'                  # manipulate file paths
join =            path.join
args         = require('minimist')(process.argv.slice 2)

gulp =            require 'gulp'                  # streaming build system
lazypipe =        require 'lazypipe'              # re-use partial streams
runSequence =     require 'run-sequence'          # execute tasks in parallel or series

# <br><br><br>


smashRoot = process.mainModule.filename.replace '/bin/smash', ''
smashPkg  = require "#{smashRoot}/package"

{dir, pkg} = project = require '../config/project'
{logger, notify, merge, execute} = util = require '../utils/util'

# {env, dir, assumptions, banner} = project


###
Auto-load all (most) Gulp plugins and attach to `$` for easy access
###
$ = require('gulp-load-plugins')(
  camelize: true
  config: smashPkg
  scope: ['dependencies']
)
$.util =        require 'gulp-util'
$.bowerFiles =  require 'main-bower-files'
$.browserSync = require 'browser-sync'
$.reload =      $.browserSync.reload
# <br><br><br>

logging  = ->  $.if args.verbose, $.using()
watching = ->  $.if args.watch, $.reload(stream: true)
caching  = (cache) ->  $.if args.watch, $.cached cache or 'main'
plumbing = ->  $.if args.watch, $.plumber(errorHandler: console.log)

time     = (f) -> moment().format(f)




# -------------------------------  API  ---------------------------------
module.exports =

  ###
  Plugins
  ###
  $: $
  # <br><br><br>

  ###
  Shortcut for conditional logging, watching in a stream
  ###
  logging: logging
  watching: watching
  plumbing: plumbing
  caching: caching
  # <br><br><br>

  ###
  Returns a source stream for a given asset type. This gives us
  a place to attach plugins that should be used for all asset groups
  and allows us to use a much cleaner syntax when building tasks.
  @method files
  @param {...String} types The desired file types
  @return {Object}
  ###
  files: (src, types, read=true, excludes) ->
    options =
      read: read
    excludeVendor = true
    excludeTest = true
    excludeIndex = true

    # Patterns for vendor files to be excluded by default
    vendorGlob = [
      "!{#{dir.compile},#{dir.build},#{dir.client}}/components/vendor{,/**}"
      "!node_modules{,/**}"
    ]

    # Patterns to ignore when not running tests
    testGlob = [
      "!#{dir.client}/components/test/**"
      "!#{dir.client}/**/*_test*"
    ]

    # Exclude index files for injection reasons
    indexGlob = [
      "!#{dir.client}/index.*"
    ]

    # Patterns for call-specific exclude (params)
    excludeGlob = if _.isString excludes
        [excludes]
      else if _.isArray excludes
        excludes
      else
        []

    # Build source glob for `gulp.src`
    source = if /vendor/.test src
      excludeVendor = false
      options.base = dir.vendor
      # ------------------------------  /client/components/vendor
      # files('vendor')
      unless types?
        $.bowerFiles()
      else
        switch types[0]
          # files('vendor', '*')
          when '*' then $.bowerFiles()
          # files('vendor', '.js')
          when '.' then $.bowerFiles(filter: new RegExp types)
          else
            # files('vendor', ['.js', '.css', '.html'])
            if _.isArray types then $.bowerFiles(filter: new RegExp types.join '|')
            else null
    else
      if _.isEmpty arguments
        # files()
        ["#{dir.client}/**/*.*"]
      else
        switch
          when _.isString(src)
            switch
              # files('*')
              when /\*/.test(src) then ["#{dir.client}/**/*.*"]
              # files('.js')
              when /\./.test(src) then ["#{dir.client}/**/*#{src}"]
              # files('compile')
              when /compile|build/.test src

                options.base = src
                unless types?
                  ["#{dir[src]}/**/*.*"]
                else
                  switch types[0]
                    # files('compile', '*')
                    when '*' then ["#{dir[src]}/**/*.*"]
                    # files('compile', '.js')
                    when '.' then ["#{dir[src]}/**/*#{types}"]
                    # files('compile', ['.js', '.css', '.html'])
                    else
                      if _.isArray types then ("#{dir[src]}/**/*#{type}"  for type in types)
                      else null
              else null

          # files(['.js', '.css', '.html'])
          when _.isArray(src) then ("#{dir.client}/**/*#{type}") for type in src
          when _.isObject(src) and !_.isArray(src)
            excludeVendor = false
            excludeIndex = false
            options.base = ''
            # files({path: 'path/to/files'}, ['.js', '.css', '.html'])
            if _.isArray types then ("#{src.path}/**/*#{t}" for t in types)
            # files({path: 'path/to/file.ext'})
            else ["#{src.path}"]

          else null

    # Create Gulp stream
    unless source?
      logger.error "!! Unknown file target '#{src}'. Could not build stream."
    else
      options.base ?= 'client'
      source = source.concat vendorGlob   if excludeVendor
      source = source.concat testGlob     if excludeTest
      source = source.concat excludeGlob  if excludeGlob.length > 0
      source = source.concat indexGlob    if excludeIndex

      gulp.src source, options
        .pipe $.if options.read, plumbing()
  # <br><br><br>


  ###
  A collection of destination objects targeting folders from
  the project config. A shortcut for having to write `.pipe(gulp.dest dir compile)`
  ###
  dest:
    compile:       ->  gulp.dest dir.compile
    build:         ->  gulp.dest dir.build
    deploy:        ->  gulp.dest dir.deploy
    client:        ->  gulp.dest dir.client
    compileVendor: ->  gulp.dest dir.vendor
  # <br><br><br>

  ###
  Returns the current time with the given format
  @method time
  @param {String} format moment.js time format
  @return {Object}
  ###
  time: time
  # <br><br><br>

  ###
  Banner placed at the top of all JS files during development.
  Overridden by value of `banner` from Smashfile unless null

  TODO: add Git branch and SHA
  ###
  banner: project?.banner or "/** \n
                              * #{pkg.name}  \n
                              * v. #{pkg.version}  \n
                              * \n
                              * Built #{time 'dddd, MMMM Do YYYY, h:mma'}  \n
                              */ \n\n"

  # <br><br><br>
