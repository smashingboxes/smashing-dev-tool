express    = require 'express'
jsonServer = require 'json-server'
logger     = require 'morgan'
bodyParser = require 'body-parser'
{join}     = require 'path'
through    = require 'through2'
fs         = require 'fs'
puer       = require 'puer'
http       = require 'http'

vantage
  .command 'serve'
  .description 'Launches a local development server'
  .action (args, cb) ->
    @log 'Launhing server...'
    # app = express()
    # server = http.createServer(app)
    #
    # opts =
    #   dir: './_testfiles'
    #   ignored: /(\/|^)\..*|node_modules/
    #
    # # app.use puer.connect(app, server, opts)
    # app.set 'views', join(__dirname, 'views')
    # app.set 'view engine', 'jade'
    # app.use logger('dev')
    # app.use bodyParser.json()
    # app.use bodyParser.urlencoded(extended: false)
    # app.use express.static(join(__dirname, 'public'))
    #
    # # app.use '/', routes
    #
    # jserv = jsonServer.create()
    # jserv.use jsonServer.defaults()
    # # jserv.get '/uplink', (req, res) ->
    # #   _.map keep, (k) ->
    # #     k.fullPath = join loc, k.path
    # #     k.stats = fs.statSync k.fullPath
    # #     k.size = k.stats.size/1000000.0
    # #   res.json keep
    # # app.get '/uplink', jserv
    #
    #
    # #  catch 404 and forward to error handler
    # app.use (req, res, next) ->
    #   err = new Error('Not Found')
    #   err.status = 404
    #   next err
    #
    # if app.get('env') == 'development'
    #   app.use (err, req, res, next) ->
    #     res.status err.status or 500
    #     res.render 'error',
    #       message: err.message
    #       error: err
    #
    # console.log app
    # cb()
