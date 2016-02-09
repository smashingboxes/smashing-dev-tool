
Liftoff = require 'liftoff'
_       = require 'lodash'
moment  = require 'moment'
q       = require 'q'
gulp    = require 'gulp'
chalk   = require 'chalk'
fs      = require 'fs'

require('dotenv').config(silent:true)

getHelpers = (project, util) ->
  self      = @
  @rootPath = smashRoot = process.mainModule.filename.replace '/bin/smush', ''
  @pkg      = smashPkg = require "#{@rootPath}/package"
  {args, logger} = util
  {dir, assets, pkg, env, build, compile} = project


  # Auto-load all (most) Gulp plugins and attach to `$` for easy access
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
    console.error err  if args.verbose
    @emit 'end'

  # replace template strings with ENV data
  templateReplace = (stream) ->
    stream
      .pipe $.data -> env:process.env
      .pipe $.template()


  plumbing    = ->  $.if args.watch, $.plumber(errorHandler: onError)
  stopPlumbing = -> $.if args.watch, $.plumber.stop()

  # See if a given path exists safely
  pathExists = (p) ->
    try
      fs.statSync(p)
      return true
    catch err
      if args.verbose
        logger.error err
      return false

  self.helpers =
    rootPath: smashRoot
    pkg:      smashPkg

    ###  Gulp Plugins  ###
    $: $
    # <br><br><br>

    ###
    Shortcut for conditional logging, watching in a stream
    ###
    logging:         logging
    watching:        watching
    plumbing:        plumbing
    stopPlumbing:    stopPlumbing
    caching:         caching
    isBuilding:      isBuilding
    isCompiling:     isCompiling
    onError:         onError
    templateReplace: templateReplace
    pathExists:      pathExists
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
      fonts:         ->  gulp.dest dir.fonts
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
                                * #{pkg?.bower?.name}  \n
                                * v. #{pkg?.bower?.version}  \n
                                * \n
                                * Built #{time 'dddd, MMMM Do YYYY, h:mma'}  \n
                                */ \n\n"

module.exports = ({project, util}) ->
  getHelpers project, util
