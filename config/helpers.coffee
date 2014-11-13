# Project-specific helpers for accessing source code consistiently regardless of project

_ =               require 'underscore'                # array and object utilities
chalk =           require 'chalk'
tildify =         require 'tildify'
moment =          require 'moment'                # time/date utils
open =            require 'open'                  # open files
fs =              require 'fs'
path =            require 'path'                  # manipulate file paths
join =            path.join

gulp =            require 'gulp'                  # streaming build system
through =         require 'through2'
lazypipe =        require 'lazypipe'              # re-use partial streams
runSequence =     require 'run-sequence'          # execute tasks in parallel or series
combine =         require 'stream-combiner'

browserSync =     require 'browser-sync'
reload =          browserSync.reload

# <br><br><br>


module.exports = (globalConfig, projectConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util
  {assets, pkg, env, dir, assumptions} = projectConfig

  $ = require('gulp-load-plugins')(
    camelize: true
    config: smash.pkg
    scope: ['dependencies']
  )

  $.util =        require 'gulp-util'
  $.bowerFiles =  require 'main-bower-files'
  $.reload =      reload

  # gulp plugins
  $: $

  ###
  Returns a source pipe for a given asset type. This gives us
  a place to attach plugins that should be used for all asset groups
  and allows us to use a much cleaner syntax when building tasks.
  @method files
  @param {...String} types The desired file types
  @return {Object}
  ###
  files: (src, types, read=true, excludes) ->
    options =
      read:read
      base: 'client'
    excludeVendor = true
    _excludes = []

    if args.verbose
      logger.debug "files(): #{ if typeof src is 'string' then src else typeof src}"

    # build source array
    source = if /vendor/.test src
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
      # exclude vendor files
      _excludes = [
        "!{#{dir.compile},#{dir.build},#{dir.client}}/components/vendor{,/**}"
        "!node_modules{,/**}"
        "!#{dir.client}/components/test/**"
      ].concat(
        if _.isString excludes then [excludes]
        else if _.isArray excludes then excludes
        else [])

      if _.isEmpty arguments
        # ------------------------------  /client
        # files('*')
        ["#{dir.client}/**/*.*"]
      else
        switch
          when _.isString(src)
            switch
              # files('*')
              when /\*/.test(src) then ["#{dir.client}/**/*.*"]
              # files('.js')
              when /\./.test(src) then ["#{dir.client}/**/*#{src}"]

              # ------------------------------  /compile, /build
              when /compile|build/.test src
                # files('compile')
                unless types?
                  ["#{dir[src]}/**/*.*"]
                else
                  switch types[0]
                    # files('compile', '*')
                    when '*' then ["#{dir[src]}/**/*.*"]
                    # files('compile', '.js')
                    when '.' then ["#{dir[src]}/**/*#{types}"]
                    else
                      # files('compile', ['.js', '.css', '.html'])
                      if _.isArray types then ("#{dir[src]}/**/*#{type}"  for type in types)
                      else null
              else null
          # files(['.js', '.css', '.html'])
          when _.isArray(src) then ("#{dir.client}/**/*#{type}") for type in src
          # files({path: 'path/to/file'})
          when _.isObject(src) and !_.isArray(src)
            console.log 'OBJECT!'
            excludeVendor = false
            ["#{src.path}"]
          else null

    # create gulp stream
    unless source?
      logger.error "!! unknown file target"
    else
      source = source.concat(_excludes)  if excludeVendor
      gulp.src source, options

  dest:
    compile:       -> gulp.dest dir.compile
    build:         ->   gulp.dest dir.build
    deploy:        ->  gulp.dest dir.deploy
    client:        ->  gulp.dest dir.client
    compileVendor: ->  gulp.dest dir.vendor

  ###
  Returns the current time with the given format
  @method time
  @param {String} format moment.js time format
  @return {Object}
  ###
  time: (f) ->
    moment().format(f)
  # <br><br><br>


  # Banner placed at the top of all JS files during development
  banner: "/** \n
            * APP_NAME
            */ \n\n"
  # <br><br><br>
