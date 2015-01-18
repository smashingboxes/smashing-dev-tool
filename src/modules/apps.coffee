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
  commands: ['bump', 'offline']
  init: (smasher) ->
    {tasks, recipes, commander, assumptions, rootPath, user, platform, project} = smasher
    {logger, notify, execute, merge, args} = util
    {files, dest, $, logging, watching, isBuilding, isCompiling} = helpers


    ### ---------------- COMMANDS ------------------------------------------- ###
    # Bump the app version and tag
    smasher.command('bump [importance]')
      .description('Increment semver in appropriate JSON file(s) and tag repo. major|minor|patch|prerelease')
      .action (importance='minor') ->
        logger.warn "Bumping version: #{importance}"
        gulp.src ['./package.json', './bower.json']
          .pipe logging()
          .pipe $.bump type:importance
          .pipe gulp.dest './'
          .pipe $.git.commit "bumps package version -- #{importance}"
          .pipe $.filter ['bower.json', 'package.json']
          .pipe $.tagVersion(prefix:'')


    ### ---------------- TASKS ---------------------------------------------- ###
    # Generate app manifest for offline mode
    smasher.task 'apps:manifest', ->
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
