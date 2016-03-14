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
exec    = require('child_process').exec
pe      = new (require 'pretty-error')()

YAML    = require 'json2yaml'

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
    description: 'Deploy an application to a given environment. staging|development|production'
    action: (environment='development') ->
      deployCmd = "tape ansible playbook --book=deploy.yml -l #{environment}"
      deployCmd += ' -vvv'  if args.verbose

      logger.info "Deploying environment: #{chalk.green environment}"
      logger.verbose "Running command: " + chalk.red deployCmd

      dArgs = deployCmd.split ' '

      deploySh = spawn dArgs[0], dArgs[1..dArgs.length-1],
        cwd:   "#{process.cwd()}"
        stdio: 'inherit'

      deploySh.stdout.on 'data', logger.info
      deploySh.stderr.on 'data', logger.error

      deploySh.on 'close', (code) ->
        if code is 0
          logger.info chalk.green 'Deploy success!'
        else
          logger.error chalk.red "Exit: #{code}"


  # Wrapper for the `tape ansible everything` commmand
  Smasher.command
    cmd: 'provision [environment]'
    description: 'Configure a remote server to host a given environment. staging|development|production'
    action: (environment='development') ->
      provisionCmd = "tape ansible everything -l #{environment}"
      provisionCmd += ' -vvv'  if args.verbose

      logger.info "Provisioning environment: #{chalk.green environment}"
      logger.verbose "Running command: " + chalk.red provisionCmd

      pArgs = provisionCmd.split ' '

      provisionSh = spawn pArgs[0], pArgs[1..pArgs.length-1],
        cwd:   "#{process.cwd()}"
        stdio: 'inherit'

      provisionSh.stdout.on 'data', logger.info
      provisionSh.stderr.on 'data', logger.error

      provisionSh.on 'close', (code) ->
        if code is 0
          logger.info chalk.green 'Provisioning success!'
        else
          logger.error chalk.red "Exit: #{code}"


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
