rest =          require 'restler'
argv =          require('minimist')(process.argv.slice 2)
inquire =       require 'inquirer'


# Register module Commands
module.exports = ({assets, tasks, args, dir, env, pkg, util, helpers, commander}) ->
  {files, vendorFiles, copyFiles, time, filters, dest, colors} = helpers
  {logger, notify, execute, $} = util

  # API Access
  do_key = '67f797894ee8624b9dc72b5be7bd44d6639907aa522cb20f2b9a4169dd00a3a6'
  GitHubApi = require("node-github")

  github = new GitHubApi
    version: "3.0.0"
    # debug: true
    protocol: "https"
    pathPrefix: "/api/v3"
    timeout: 5000

  github.authenticate
    type: "oauth"
    key: "87b39d7b6116996a64a2"
    secret: "313b60a654df8a5efcd3449074557c4087dd57db"
    token: "0a95788d83ff7b526d493351a13f22dbd522fd6e"


  # Configure module Tasks
  tasks.add 'apps:list:github', ->
    logger.info 'getting apps from GitHub'
    github.repos.getFromOrg
      type: 'all'
      org: 'smashingBoxes'
      (err, res) ->
        for r in res
          console.log r.name

  tasks.add 'apps:list:digitalocean', ->
    logger.info 'getting apps from DigitalOcean'
    rest
      .get('https://api.digitalocean.com/v2/droplets', accessToken: do_key)
      .on('complete', (result)->
        for ret in result.droplets
          console.log ret.name
      )

  commander
    .command('apps')
    .description('deploy application to specified remote enviornment')
    .option('-b, --bold',         'Display detailed log information')
    .action ->

      # store task names, remove first member as it is consumed by commander.js
      args = argv._.reverse()
      args.pop()

      switch args.pop()
        when 'list'
          inquire.prompt [
            type: "list"
            name: "service"
            message: "For which service do you want to list Apps?",
            choices: ["DigitalOcean", "GitHub"]
            filter: (val) -> val.toLowerCase()
          ], (answers) ->
            switch answers.service
              when 'digitalocean'
                tasks.start('apps:list:digitalocean')
              when 'github'
                tasks.start('apps:list:github')
