Ship = require 'ship'

module.exports = (vantage) ->

  vantage
    .command 'deploy'
    .description 'Deploys the web app with Ship.js'
    .action (args, cb) ->
      @log 'starting deploy...'
      project = new Ship root: './_testfiles', deployer: 's3'

      deployIt = ->
        project
          .deploy './dist'
          .progress console.log.bind(console)
          .done (res) ->
            console.log 'successfully deployed!'
            cb()
          , (err) ->
            console.log 'error!'
            console.log err
            cb()

      unless project.is_configured()
        project
          .config_prompt()
          .then ->
            console.log 'configured!'
            project.write_config()
            deployIt()
      else
        deployIt()
