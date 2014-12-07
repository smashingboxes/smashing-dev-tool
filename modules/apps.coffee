rest    = require 'restler'
argv    = require('minimist')(process.argv.slice 2)
inquire = require 'inquirer'
gulp    = require 'gulp'

smasher = require '../config/global'
project = require '../config/project'
util    = require '../utils/util'
helpers = require '../utils/helpers'

smasher.module
  name:     'apps'
  commands: ['apps', 'bump']
  init: (smasher) ->
    {args, tasks, recipes, commander, assumptions, rootPath, user, platform, project} = smasher
    {logger, notify, execute, merge} = util
    {files, dest, $, logging, watching} = helpers


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


    ### ---------------- COMMANDS ------------------------------------------- ###
    smasher.command('apps')
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

    smasher.command('bump [importance]')
      .description('Increment semver in appropriate JSON file(s) and tag repo')
      .action (importance='minor') ->
        logger.warn "Bumping version: #{importance}"
        gulp.src ['./package.json', './bower.json']
          .pipe logging()
          .pipe $.bump type:importance
          .pipe gulp.dest './'
          .pipe $.git.commit "bumps package version -- #{importance}"
          .pipe $.filter 'package.json'
          .pipe $.tagVersion()



    ### ---------------- TASKS ---------------------------------------------- ###
    smasher.task 'apps:list:github', ->
      logger.info 'getting apps from GitHub'
      github.repos.getFromOrg
        type: 'all'
        org: 'smashingBoxes'
        (err, res) ->
          for r in res
            console.log r.name

    smasher.task 'apps:list:digitalocean', ->
      logger.info 'getting apps from DigitalOcean'
      rest
        .get('https://api.digitalocean.com/v2/droplets', accessToken: do_key)
        .on('complete', (result)->
          for ret in result.droplets
            console.log ret.name
        )
