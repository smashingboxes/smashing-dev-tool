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

replaceDot = (path) ->
  if path.basename[0] is "_"
    path.basename = ".#{path.basename.slice 1}"
  path

templates = ['ember', 'polymer', 'angular']

# Register module Commands
module.exports = ({args, util, tasks, commander, assumptions, smash, user, platform}) ->
  {logger, notify, execute} = require '../config/util'
  prompts = []
  answers = {}
  templateFiles = null
  template = null

  # Load the requested template, prompts and files reference
  tasks.add 'generate:load-template', (done) ->
    template = args._[1]
    unless _.contains templates, template
      logger.error "Template '#{template}' is not recognized!"
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
  tasks.add 'generate:app', ['generate:prompt-new-app', 'generate:load-template'], (done) ->
    logger.info "Generating app '#{chalk.magenta(answers.appNameSlug)}' from template '#{chalk.yellow(template)}'"
    templateFiles()
      .pipe $.using()
      .pipe $.template answers
      .pipe $.rename replaceDot
      .pipe $.conflict '.'
      .pipe gulp.dest '.'
      .pipe $.install()
      .on "end", done

  commander
    .command('generate')
    .description('generate app from template')
    .action ->
      tasks.start 'generate:app'

  # commander
  #   .command('generate:clean')
  #   .description('generate app from template')
  #   .action ->
  #     rimraf = force: true, read: false
  #     gulp.src 'generated'
  #       .pipe $.using()
  #       .pipe $.rimraf rimraf
