_ =             require 'underscore'
_.str =         require 'underscore.string'
gulp =          require 'gulp'
chalk =         require 'chalk'
inquirer =      require 'inquirer'
fs =            require 'fs'

prompts = []
answers = {}
target = null
template = null
templateFiles = null
overwriteDir = false

# templates = ['ember', 'polymer', 'simple', 'angular', 'angular-amd']
templates = ['angular', 'angular-amd', 'simple']

replaceDot = (path) ->
  if path.basename[0] is "_"
    path.basename = ".#{path.basename.slice 1}"
  path


module.exports = (Smasher) ->
  {commander, assumptions, rootPath, pkg, user, platform, project, util, helpers} = Smasher
  {logger, notify, execute, merge} = util
  {files, $, dest} = helpers


  ### ---------------- COMMANDS ------------------------------------------- ###
  Smasher.command
    cmd: 'new <name>'
    alias: 'n'
    description: 'generate app from template'
    action: (name, options) ->
      console.log 'NEW TIME!'
      target = name
      self.startTask 'generate:app'

  Smasher.command
    cmd: 'generate <name>'
    alias: 'g'
    description: 'generate component from template'
    action: (name, options) ->
      target = name
      self.startTask 'generate:component'

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
      default:  'simple'
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
          "#{rootPath}/src/templates/#{template}/**/*"
        ]
      done()

  # Prompt for template variables
  Smasher.task 'generate:prompt-new-app', ['generate:load-template'], (done) ->
    logger.info 'Gathering information'
    inquirer.prompt prompts, (ans) ->
      console.log ans
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
    logger.info "Generating #{chalk.magenta('components/' + target)}"
    done()
