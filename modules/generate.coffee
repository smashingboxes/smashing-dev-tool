_ =             require 'underscore'
_.str =         require 'underscore.string'
gulp =          require 'gulp'
async =         require 'async2'
lazypipe =      require 'lazypipe'
chalk =         require 'chalk'
inquirer =      require 'inquirer'
fs =            require 'fs'
$ =
  using:        require 'gulp-using'
  template:     require 'gulp-template'
  conflict:     require 'gulp-conflict'
  rename:       require 'gulp-rename'
  install:      require 'gulp-install'

templates = ['ember', 'polymer', 'angular']

replaceDot = (path) ->
  if path.basename[0] is "_"
    path.basename = ".#{path.basename.slice 1}"
  path


# Register module Commands
module.exports = ({args, util, tasks, commander, assumptions, smash, user, platform}) ->
  {logger, notify, execute} = require '../config/util'
  prompts = []
  answers = {}
  target = null
  template = null
  templateFiles = null

  overwriteDir = false

  ### NEW APP GENERATION ###

  tasks.add 'generate:check-dir', (done) ->
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


  # Load the requested template, prompts and files reference
  tasks.add 'generate:load-template', ['generate:check-dir'], (done) ->
    inquirer.prompt [{
      name:     'template'
      message:  'What type of app do you want to generate?'
      type:     'list'
      choices:  templates
      default:  'angular'
    }], ({template}) ->
      unless template and fs.existsSync "#{smash.root}/templates/#{template}"
        logger.error "Could not find template '#{chalk.red template}'"
        process.exit 1

      prompts = require "#{smash.root}/templates/#{template}/prompts.json"

      # replace prompt default placeholders with global config values where appropriate
      for prompt in prompts
        if prompt.default and (typeof prompt.default is 'string') and (prompt.default.match /default\./)
          keys = prompt.default.replace('default.', '').split('.')
          prompt.default = switch
            when keys[0] is 'user'
              user[keys[1]]
            when keys[0] is 'platform'
              platform[keys[0]]

      templateFiles = ->
        gulp.src [
          "!#{smash.root}/templates/#{template}/prompts.json"
          "#{smash.root}/templates/#{template}/**/*"
        ]
      done()

  # Prompt for template variables
  tasks.add 'generate:prompt-new-app', ['generate:load-template'], (done) ->
    logger.info 'Gathering information'
    inquirer.prompt prompts, (ans) ->
      ans.appNameSlug = _.str.slugify ans?.appName
      answers = ans
      done()

  # Generate app from template files
  tasks.add 'generate:app', ['generate:prompt-new-app'], (done) ->
    logger.info "Generating app '#{chalk.magenta(answers.appNameSlug)}' from template '#{chalk.yellow(template)}'"
    logger.info "Creating project directory #{chalk.magenta target}"

    fs.mkdirSync target  unless overwriteDir

    templateFiles()
      .pipe $.using()
      .pipe $.template answers
      .pipe $.rename replaceDot
      .pipe $.conflict '.'
      .pipe gulp.dest target
      .pipe $.install()
      .on "end", done


  ### COMPONENT SCAFFOLDING ###
  tasks.add 'generate:component', (done) ->
    logger.info 'Generating component'
    done()



  commander
    .command('generate <type> <path>')
    # .alias('g')
    .description('generate app from template')
    .action (type, path, options) ->
      target = path
      switch type
        when 'app'
          tasks.start 'generate:app'
        when 'component'
          tasks.start 'generate:component'
        else
          logger.error "I don't know how to generate '#{chalk.red target}'!"
