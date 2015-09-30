# rest       = require 'restler'
argv         = require('minimist')(process.argv.slice 2)
inquire      = require 'inquirer'
gulp         = require 'gulp'
_            = require 'underscore'
chalk        = require 'chalk'
YAML         = require 'json2yaml'
u            = require 'util'
fs           = require 'fs'
http         = require 'http'
path         = require 'path'
spawn        = require('child_process').spawn
pe           = new (require 'pretty-error')()


swaggerTools = require('swagger-tools')
swagger      = require 'swagger-parser'
swApp        = require('connect')()


module.exports = (Smasher) ->
  {commander, assumptions, user, platform, project, util, helpers} = Smasher
  {logger, notify, execute, merge, args} = util
  {files, dest, $, logging, watching, isBuilding, isCompiling, rootPath, pkg} = helpers

  sw = project.swagger

  paths =
    schemaSrc:     path.resolve sw.path, (sw.schemaPath or ''), sw.schemaFile  # or "schema/swagger.json"
    schemaUrl:                  sw.schemaUrl               # or "/api-docs"
    partialsIndex: path.resolve sw.path, sw.partialsDir, sw.partialsIndex
    uiSrc:         path.resolve sw.uiSrc                   or "#{helpers.rootPath}/src/modules/swagger/ui"
    controllers:   path.resolve sw.path, sw.controllersDir #or "schema/controllers"
    partials:      path.resolve sw.path, sw.partialsDir    # or "schema/definitions"
    uiUrl:                      sw.uiUrl                   #or "/docs"

  serverPort = sw.port



  ### ---------------- COMMANDS ------------------------------------------- ###
  commands = {}
  # Project schema commands via Swagger
  Smasher.command
    cmd: 'swagger [command]'
    description: 'Run a Swagger command on the local schema'
    action: (command='validate') ->
      if c = commands[command] then c()
      else
        logger.error "Could not find command `#{chalk.red.bold 'swagger ' + command}`"


  validateSchema = (done) ->
    console.log ''
    logger.warn 'Validating Swagger schema...'

    swagger.parse paths.partialsIndex, sw.parser, (err, api, metadata) ->
      # Schema is valid
      unless err
        logger.info chalk.green "Validation SUCCESS"
        logger.info "API name: #{chalk.blue api.info.title}, Version: #{chalk.blue api.info.version}"
        logger.verbose u.inspect api, showHidden:false, depth:null

        # Dynamically generate swagger.yaml
        apiyaml = YAML.stringify api
        logger.verbose apiyaml
        fs.writeFile paths.schemaSrc, (JSON.stringify api), 'utf8', ->
          logger.verbose "Generated dynamic #{chalk.green project.swagger.schemaFile} from project schema"
          done()

      # Schema is invalid
      else
        logger.error chalk.red "Validation FAILED"
        logger.error pe.render err
        done()

  mockServer = ->
    swaggerDoc = require paths.schemaSrc
    logger.info 'Mocking API endpoints based on schema definition'

    # Initialize the Swagger middleware
    swaggerTools.initializeMiddleware swaggerDoc, (middleware) ->

      # Interpret Swagger resources and attach metadata to request
      # - must be first in swagger-tools middleware chain
      swApp.use middleware.swaggerMetadata()

      # Validate Swagger requests
      swApp.use middleware.swaggerValidator()

      # Route validated requests to appropriate controller
      swApp.use middleware.swaggerRouter(
        controllers: paths.controllers
        useStubs:    sw.mockResponses or false
      )

      # Serve the Swagger documents and Swagger UI
      swApp.use middleware.swaggerUi(
        apiDocs:      paths.schemaUrl
        swaggerUi:    paths.uiUrl
        swaggerUiDir: paths.uiSrc
      )

      # Start the server
      http.createServer(swApp).listen serverPort, ->
        g = chalk.green "(http://localhost:#{serverPort}#{paths.uiUrl})"
        logger.info "Your Swagger API is listening on port #{serverPort} #{g}"

  gulp.task 'swagger:mock', mockServer
  commands.mock = ->
    validateSchema ->
      mockServer()
      commands.watch()




  commands.watch = ->
    logger.info "Watching #{chalk.magenta '.yml'} files for changes"
    gulp.watch [
      "#{paths.partials}/**/*.{yml,yaml}",
      "!#{paths.partials}/**/swagger.{yml,yaml}"
    ], ['swagger:validate']


  gulp.task 'swagger:validate', validateSchema
  commands.validate = ->
    validateSchema ->
      gulp.watch [
        "#{paths.partials}/**/*.{yml,yaml}",
        "!#{paths.partials}/**/swagger.{yml,yaml}"
      ], ['swagger:validate']



  ### ---------------- TASKS ---------------------------------------------- ###
