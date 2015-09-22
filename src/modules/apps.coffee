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

  # Project schema commands via Swagger
  Smasher.command
    cmd: 'swagger [command]'
    description: 'Run a Swagger command on the local schema'
    action: (command='validate') ->
      swOpts =
        dereferenceInternal$Refs: true
        dereference$Refs: true
      schemaPath = 'api/swagger'
      # gulp.src [
      #   # "#{schemaPath}/**/*.{yaml,yml}"
      #   "#{schemaPath}/**/swagger.{yaml,yml}"
      # ]
      #   .pipe $.using()
      #   .pipe $.swagger
      #     filename: 'api.js'
      #     type: 'angular'
      #   .pipe gulp.dest 'swDest'

      validate = (done) ->
        console.log ''
        logger.warn 'Validating Swagger schema...'
        swagger.parse "#{schemaPath}/index.yml", swOpts, (err, api, metadata) ->
          # Schema is valid
          unless err
            logger.info chalk.green "Validation SUCCESS"
            logger.info "API name: #{chalk.blue api.info.title}, Version: #{chalk.blue api.info.version}"
            logger.verbose u.inspect api, showHidden:false, depth:null

            # Dynamically generate swagger.yaml
            apiyaml = YAML.stringify api
            logger.verbose apiyaml
            fs.writeFile "#{schemaPath}/swagger.json", (JSON.stringify api), 'utf8', ->
              logger.verbose "Generated dynamic #{chalk.green 'swagger.yml'} from project schema"
              done()

          # Schema is invalid
          else
            logger.error chalk.red "Validation FAILED"
            logger.error pe.render err
            done()

      validate ->
        gulp.task 'swagger', validate
        gulp.watch [
          "#{schemaPath}/**/*.{yml,yaml}",
          "!#{schemaPath}/**/swagger.{yml,yaml}"
        ]
        , ['swagger']


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
