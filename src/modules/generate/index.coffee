_               = require 'underscore'
_.str           = require 'underscore.string'
gulp            = require 'gulp'
chalk           = require 'chalk'
inquirer        = require 'inquirer'
fs              = require 'fs'
del             = require 'del'
path            = require 'path'
open            = require 'open'
spawn           = require('child_process').spawn
streamToPromise = require 'stream-to-promise'
source          = require 'vinyl-source-stream'

prompts         = []
answers         = {}
target          = null
template        = null
templateFiles   = null
overwriteDir    = false

templates = [
  # 'ember-simple'
  # 'polymer-simple'
  # 'react-simple'
  'angular-bootstrap-simple'
  'angular-material-simple'
  'angular-webpack'
  'webpack-simple'
  # 'angular-material-amd'
]

replaceDot = (p) ->
  if p.basename[0] is "_"
    p.basename = ".#{p.basename.slice 1}"
  p


module.exports = (Smasher) ->
  {commander, assumptions, user, platform, project, util, helpers} = Smasher
  {logger, notify, execute, merge, args} = util
  {files, $, dest, rootPath, pkg, logging} = helpers


  stringStream = (filename, string) ->
    src = require('stream').Readable objectMode:true
    src._read = ->
      @push new $.util.File
        cwd:      ''
        base:     ''
        path:     filename
        contents: new Buffer string
      @push null
    src



  ### ---------------- COMMANDS ------------------------------------------- ###
  Smasher.command
    cmd: 'new <name>'
    alias: 'n'
    description: 'generate app from template'
    action: (name, options) ->
      target = name
      Smasher.startTask 'generate:app'

  Smasher.command
    cmd: 'generate <name>'
    alias: 'g'
    description: 'generate component from template'
    options: [
      opt: '--name,-n'
      description: 'Name of the component element'
    ]
    action: (name, options) ->
      if project.generator?
        Smasher.startTask 'generate:component'
      else
        logger.error "No generator defined in Smashfile"


  ### ---------------- TASKS ---------------------------------------------- ###
  # Handle existing folder
  Smasher.task 'generate:check-dir', (done) ->
    if fs.existsSync target
      inquirer.prompt [{
        name:     'overwrite'
        message:  "Directory '#{chalk.magenta target}' already exists. Continue?"
        type:     'confirm'
        default:  false
      }], ({overwrite}) ->
        process.exit 1  unless overwrite
        overwriteDir = true
        done()
    else
      done()

  # Load the requested template, prompts and files reference
  Smasher.task 'generate:load-template', ['generate:check-dir'], (done) ->
    inquirer.prompt [{
      name:     'template'
      message:  'What type of app do you want to generate?'
      type:     'list'
      choices:  templates
      default:  templates[0]
    }], ({template}) ->
      unless template and fs.existsSync "#{rootPath}/src/templates/#{template}"
        logger.error "Could not find template '#{chalk.red template}'"
        process.exit 1

      prompts = require "#{rootPath}/src/templates/#{template}/prompts.json"
      # replace prompt default placeholders with global config values where appropriate
      for prompt in prompts
        if prompt.default and (typeof prompt.default is 'string') and (prompt.default.match /default\./)
          keys = prompt.default.replace('default.', '').split('.')
          prompt.default = switch
            when keys[0] is 'user'      then user[keys[1]]
            when keys[0] is 'platform'  then platform[keys[0]]
            when keys[0] is 'commander' then target

      templateFiles = ->
        gulp.src [
          "!#{rootPath}/src/templates/#{template}/prompts.json"
          "!#{rootPath}/src/templates/#{template}/generate{,/**}"
          "#{rootPath}/src/templates/#{template}/**/*"
        ]
      done()

  # Prompt for template variables
  Smasher.task 'generate:prompt-new-app', ['generate:load-template'], (done) ->
    logger.info 'Gathering information'
    inquirer.prompt prompts, (ans) ->
      logger.data ans  if args.verbose
      ans.appNameSlug = _.str.slugify ans?.appName
      answers = ans
      done()

  # Generate app from template files
  Smasher.task 'generate:app', ['generate:prompt-new-app'], ->
    logger.info "Generating app '#{chalk.magenta(answers.appNameSlug)}' from template '#{chalk.yellow template}'"
    logger.info "Creating project directory #{chalk.magenta target}"

    fs.mkdirSync target  unless overwriteDir

    templateFiles()
      .pipe $.using()
      .pipe $.template answers
      .pipe $.conflict '.'
      .pipe $.rename replaceDot
      .pipe gulp.dest target
      .pipe $.install()

  # Scaffold Tasks
  Smasher.task 'generate:component', (done) ->
    target   = args._.pop()
    nameSlug = target.split('/').pop()
    type     = args._.pop()

    prefix = switch type
      when 'directive' then "components"
      when 'controller', 'factory', 'service' then ""

    logger.info "Generating new #{chalk.green(type)} in #{chalk.magenta(target)}"
    data =
      name:         args.name
      nameSlug:     nameSlug
      appName:      project.pkg.bower.name
      templatePath: target

    logger.data data

    gulp.src "#{rootPath}/src/templates/#{project.generator}/generate/#{type}/**/*"
      .pipe $.template data

      .pipe $.rename (p) ->
        p.basename = p.basename.replace 'template', nameSlug
        p
      .pipe $.conflict "#{project.dir.client}/#{target}"
      .pipe gulp.dest "#{project.dir.client}/#{target}"
      .pipe $.using()


  ## Electron Wrapper
  devMode = false
  Smasher.command
    cmd: 'electron'
    alias: 'e'
    description: 'build with Electron wrapper'
    options: [
      opt:'--dev'
      description:'Load dev server URL rather than index.html'
    ]
    action: (sub, options) ->
      if @dev
        devMode = true
      if _.isString sub
        Smasher.startTask "electron:#{sub}"
      else
        Smasher.startTask 'electron:run'

  Smasher.task 'electron:clean', (done) ->
    for d in ['release', 'cache']
      if fs.existsSync dx = "./#{d}"
        logger.info "Deleting #{chalk.magenta dx}"
        del [dx]

  Smasher.task 'electron:run', ['electron:build'], (done) ->
    logger.info "Launching app in Electron"
    gulp.src("**/#{project.pkg.npm.name}.app")
      .pipe logging()
      .pipe $.tap (file) ->
        electron = "./#{file.relative}/Contents/MacOS/Electron"
        source   = project.dir.compile
        util.execute "#{electron} #{source}"

  Smasher.task 'electron:ensure-index', (done) ->
    logger.info "Ensuring app is electron-compatible..."

    g = files('compile')
      .pipe $.using()
      .pipe $.expectFile {reportUnexpected:false, errorOnFailure:true}, project.electron.entryPoint

    (streamToPromise g)
      .then -> done()
      .catch (error) ->
        logger.error 'Could not find JS entrypoint for Electron, injecting bootstrap script'
        file   = "file://#{project.env.cwd}/#{project.dir.compile}/index.html"
        server = "http://localhost:8080"
        url    = if devMode then server else file

        s = gulp.src "#{helpers.rootPath}/src/modules/generate/electron-index.coffee"
          .pipe $.using()
          .pipe $.template appUrl: url
          .pipe $.coffee()
          .pipe dest.compile()
        (streamToPromise s)
          .then -> done()


    return

  Smasher.task 'electron:build', ['electron:ensure-index'], (done) ->
    logger.info "Building app in Electron wrapper"
    pkgJson = project.pkg.npm
    pkgJson.main = project.electron.entryPoint
    gulp.src('')
      .pipe $.electron
        src:               project.electron.src
        packageJson:       pkgJson
        release:           project.electron.release
        cache:             project.electron.cache
        version:           project.electron.version
        packaging:         project.electron.packaging
        platforms:         project.electron.platforms
        platformResources:
          darwin:
            CFBundleDisplayName: project.pkg.npm.name
            CFBundleIdentifier:  project.pkg.npm.name
            CFBundleName:        project.pkg.npm.name
            CFBundleVersion:     project.pkg.npm.version
            # icon:                'gulp-electron.icns'





  Smasher.command
    cmd: 'clean:vendor'
    action: ->
      if fs.existsSync dx = "./client/components/vendor"
        logger.info "Deleting #{chalk.magenta dx}"
        del [dx]
      else
        logger.warn 'Could not find "./client/components/vendor"'


  # Download Google Webfonts and generate CSS
  Smasher.command
    cmd: 'fonts [sub]'
    action: (sub) ->
      switch sub
        when 'clean' then Smasher.startTask 'generate:fonts:clean'
        else Smasher.startTask 'generate:fonts'

  Smasher.task 'generate:fonts', ->
    stream = null
    if fonts = project.googleWebfonts
      logger.info "Caching Google Webfonts in #{chalk.magenta project.dir.fonts}"
      fontList = ("#{font}:#{weights}" for font, weights of fonts).join('\n') + '\n'
      stream = stringStream 'fonts.list', fontList
      stream
        # .pipe $.cat()
        .pipe $.googleWebfonts()
        .pipe logging()
        .pipe dest.fonts()

    else
      logger.warn 'No Google Web Fonts config specified'

    stream

  Smasher.task 'generate:fonts:clean', ->
    if fs.existsSync dx = project.dir.fonts
      logger.info "Deleting #{chalk.magenta dx}"
      del [dx]
    else
      logger.warn "Could not find #{chalk.magenta project.dir.fonts}"
