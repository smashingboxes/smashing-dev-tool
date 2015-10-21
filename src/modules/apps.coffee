# rest  = require 'restler'
argv    = require('minimist')(process.argv.slice 2)
inquire = require 'inquirer'
gulp    = require 'gulp'
_       = require('underscore')
chalk   = require 'chalk'
swagger = require 'swagger-parser'
u       = require 'util'
fs      = require 'fs'

spawn   = require('child_process').spawn
pe = new (require 'pretty-error')()

YAML = require 'json2yaml'

module.exports = (Smasher) ->
  {commander, assumptions, user, platform, project, util, helpers} = Smasher
  {logger, notify, execute, merge, args} = util
  {files, dest, $, logging, watching, isBuilding, isCompiling, rootPath, pkg} = helpers


  ### ---------------- COMMANDS ------------------------------------------- ###
  # Bump the app version and tag
  Smasher.command
    cmd: 'bump [importance]'
    description: 'Increment version and tag repo. major|minor|patch|prerelease'
    action: (importance='patch') ->
      logger.warn "Bumping version: #{importance}", logging
      gulp.src ['./bower.json']
        .pipe logging()
        .pipe $.bump type:importance
        .pipe gulp.dest './'
        .pipe $.git.commit "bumps package version -- #{importance}"
        .pipe $.filter ['bower.json']
        .pipe $.tagVersion(prefix:'')

  # A simple wrapper around an Ansible deploy script
  Smasher.command
    cmd: 'deploy [environment]'
    description: 'Deploy an application to a given enviornment. staging|development|production'
    action: (environment='staging') ->
      logger.info "Deploying to environment: #{chalk.green environment}"

      deploySh = spawn 'sh', [ 'deploy.sh' ],
        cwd: "#{process.cwd()}/devops/staging"
        stdio: 'inherit'


  ### ---------------- TASKS ---------------------------------------------- ###
  # Generate app manifest for offline mode
  Smasher.task 'apps:manifest', ->
    src = switch
      when isBuilding then 'build'
      when isCompiling then 'compile'

    logger.info 'Generating app manifest'
    files(src)
      .pipe($.manifest
          hash: true
          timestamp: false
          preferOnline: true
          fallback: [
            'api/picture/ images/placeholder.png'
          ]
          filename: 'app.manifest'
          exclude: [
            'app.manifest'
            'robots.txt'
          ]
      )
      .pipe replace new RegExp('\/%20', 'g'), '/ '
      .pipe dest.compile()
