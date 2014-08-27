gulp = require 'gulp'

_ =             require 'underscore.string'
inquirer =      require 'inquirer'
iniparser =     require 'iniparser'
fs =            require 'fs'


# Register module Commands
module.exports = (project) ->
  {tasks, dir, commander} = project
  {files, templateFiles, time, dest, $} = project.helpers
  {logger, notify, execute} = project.util

  format = (string) ->
    username = string.toLowerCase()
    username.replace /\s/g, ""

  defaults = (->
    homeDir =         process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE
    configFile =      homeDir + "/.gitconfig"
    user =            if fs.existsSync(configFile) then iniparser.parseSync(configFile).user else {}

    appName:      process.cwd().split("/").pop().split("\\").pop()
    userName:     format(user.name) or (homeDir and homeDir.split("/").pop()) or "root"
    authorEmail:  user.email or ""
  )()


  tasks.add "generate", (done) ->
    prompts = [
      {
        name: "appName"
        message: "What is the name of your project?"
        default: defaults.appName
      }
      {
        name: "appDescription"
        message: "What is the description?"
      }
      {
        name: "appVersion"
        message: "What is the version of your project?"
        default: "0.1.0"
      }
      {
        name: "authorName"
        message: "What is the author name?"
      }
      {
        name: "authorEmail"
        message: "What is the author email?"
        default: defaults.authorEmail
      }
      {
        name: "userName"
        message: "What is the github username?"
        default: defaults.userName
      }
      {
        type: "confirm"
        name: "moveon"
        message: "Continue?"
      }
    ]

    #Ask
    inquirer.prompt prompts, (answers) ->
      # done()  unless answers.moveon
      answers.appNameSlug = _.slugify(answers.appName)
      # gulp.src(['./**/*']).pipe($.using())
      templateFiles('angular')
        .pipe $.using()
        .pipe $.template(answers)
        .pipe $.rename((file) -> file.basename = "." + file.basename.slice(1)  if file.basename[0] is "_")
        .pipe $.conflict("./")
        .pipe dest.client()
        .pipe $.install()
        .on "end", done

  commander
    .command('generate')
    .description('generate app from template')
    .action ->
      tasks.start 'generate'
