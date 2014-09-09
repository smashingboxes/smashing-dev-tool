connect =         require 'connect'
http =            require 'http'
express =         require 'express'
bodyParser =      require 'body-parser'
errorHandler =    require 'errorhandler'
methodOverride =  require 'method-override'
open =            require 'open'


module.exports = (globalConfig) ->
  {assets, env, dir, pkg, helpers} = globalConfig.getProject()

  start: ->
    app = express()
    port = parseInt(process.env.PORT, 10) or 4567
    # app.get "/", (req, res) ->
    #   res.redirect "/index.html"

    app.use methodOverride()
    app.use bodyParser.json()
    app.use bodyParser.urlencoded(extended: true)
    app.use express.static "./#{dir.compile}"
    app.use errorHandler(
      dumpExceptions: true
      showStack: true
    )
    console.log "Simple static server listening at http://localhost:" + port

    app.listen port
    open "http://localhost:4567"
