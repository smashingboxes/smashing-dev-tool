Ship = require 'ship'

module.exports = (vantage) ->

  vantage
    .command 'deploy'
    .description 'Deploys the web app with Ship.js'
    .action (args, cb) ->
      @log 'starting deploy...'
      project = new Ship root: './_testfiles', deployer: 's3'
      console.log project
      cb()
