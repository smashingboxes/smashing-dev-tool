# Project-specific helpers for accessing source code consistiently regardless of project

_ =               require 'lodash'                # array and object utilities
chalk =           require 'chalk'
tildify =         require 'tildify'
moment =          require 'moment'                # time/date utils
open =            require 'open'                  # open files
fs =              require 'fs'
path =            require 'path'                  # manipulate file paths
join =            path.join

gulp =            require 'gulp'                  # streaming build system
# <br><br><br>


smashRoot = process.mainModule.filename.replace '/bin/smash', ''
smashPkg  = require "#{smashRoot}/package"

{dir, pkg, assumptions, build}          = project       = require '../config/project'
{logger, notify, merge, execute, args} = util    = require '../utils/util'


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

logging     = ->  $.if args.verbose, $.using()
watching    = ->  $.if args.watch, $.reload(stream: true)
caching     = (cache) ->  $.if args.watch, $.cached cache or 'main'

time        = (f) -> moment().format(f)
isBuilding  = _.contains args._, 'build'
isCompiling = _.contains args._, 'compile'




onError = (err) ->
  $.util.beep()
  # console.error err
  @emit 'end'
plumbing    = ->  $.plumber(errorHandler: onError)
stopPlumbing = -> $.plumber.stop()



# -------------------------------  API  ---------------------------------
module.exports =

  ###
  Gulp Plugins
  ###
  $: $
  # <br><br><br>

  ###
  Shortcut for conditional logging, watching in a stream
  ###
  logging:      logging
  watching:     watching
  plumbing:     plumbing
  stopPlumbing: stopPlumbing
  caching:      caching
  isBuilding:   isBuilding
  isCompiling:  isCompiling
  onError:      onError
  # <br><br><br>


  ###
  Returns a source stream for a given asset type. This gives us
  a place to attach plugins that should be used for all asset groups
  and allows us to use a much cleaner syntax when building tasks.
  @method files
  @param {...String} types The desired file types
  @return {Stream}
  ###
  files: (src, types, read=true, excludes) ->
    fileArgs = arguments

    # Incorporate local build config from smashfile
    buildConfig   = _.values(project.build)[0]
    compileConfig = project.compile

    alts = if buildConfig?.alternates?
      (alt for alt in buildConfig?.alternates)
    else []

    # Helpers
    isExt = (s) -> _.isString(s) and s[0] is '.'
    isntExt = (s)-> _.isString(s) and s[0] isnt '.'
    invert = -> _.map(arguments[0], (g) -> "!#{g}")  # negate a glob
    isFilePath = (p) -> /\./.test p

    # Build file extension filter
    _filter =
      (if      a = _.find(fileArgs, _.isArray) then  a
      else if a = _.find(fileArgs, isExt)     then [a]
      else ['.*']).join '|'

    # Compute file query folder/scope
    _target =
      if _.find(fileArgs, _.isPlainObject) then 'path'
      else if a = _.find(fileArgs, isntExt)
        if _.contains(['vendor', 'build', 'compile', 'test'], a) then a else 'client'
      else 'client'

    # Find `read` flag
    _read =
      if (reed = _.find fileArgs, _.isBoolean)? then reed
      else if _config?.read? then _config.read
      else true

    # Find config object
    _config = if a = _.find(fileArgs, _.isPlainObject) then a else {}

    # Compute base path
    _path = [
      if p = _config?.path
        if isFilePath p then p
        else "#{p}/**/*+(#{_filter})"
      else "#{dir[_target]}/**/*+(#{_filter})"
    ]


    # Build out properly formatted
    getExcludes = ->
      ex = switch
        when _.isString excludes  then [excludes]
        when _.isArray excludes   then  excludes
        else []
      invert ex

    getBuildExcludes = ->
      if isBuilding and buildConfig.exclude?
        invert buildConfig.exclude
      else []

    getCompileExcludes = ->
      if compileConfig.exclude?
        invert compileConfig.exclude
      else []

    getAlternates = ->
      for alt in alts
        if isBuilding then "!#{alt[0]}" else "!#{alt[1]}"


    cfg =
      bower:
        includeDev: (if isBuilding then false else 'inclusive')
        filter:     new RegExp _filter

    globs =
      vendor:         ["**/components/vendor{,/**}"]
      vendorMain:     $.bowerFiles cfg.bower
      test:           ["#{dir.client}/**/*_test*"]
      index:          ["#{dir.client}/index.*"]
      alternates:     getAlternates()     or []
      exclude:        getExcludes()
      buildExclude:   getBuildExcludes()
      compileExclude: getCompileExcludes()

    # Build source glob for Gulp
    source = switch _target
      when 'client', 'compile', 'build'
        _path
          .concat        globs.alternates
          .concat invert globs.vendor
          .concat invert globs.test
          .concat        globs.exclude
          .concat        (if isBuilding  then globs.buildExclude   else [])
          .concat        (if isBuilding  then globs.compileExclude else [])
      when 'test'   then globs.test
      when 'vendor' then globs.vendorMain
      when 'path'
        _path
          .concat        (if isBuilding  then globs.buildExclude   else [])
          .concat        (if isBuilding  then globs.compileExclude else [])
      else logger.error "!! Unknown file target '#{src}'. Could not build stream."


    # Debug logging
    if args.debug
      logger.debug
        target:       chalk.red     _target
        path:         chalk.magenta _path
      logger.debug
        read:         chalk.red     _read
        exclude:      chalk.yellow  globs.exclude
        buildExclude: chalk.yellow  globs.buildExclude
      console.log source

    gulp.src(source, read: _read, base: dir[_target] or '')
      .pipe $.plumber(errorHandler: onError)
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
