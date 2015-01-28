# rest    = require 'restler'
argv    = require('minimist')(process.argv.slice 2)
inquire = require 'inquirer'
gulp    = require 'gulp'

module.exports =
  name:     'apps'
  init: (donee) ->
    self = @
    {commander, assumptions, rootPath, pkg, user, platform, project, util, helpers} = self
    {logger, notify, execute, merge, args} = util
    {files, dest, $, logging, watching, isBuilding, isCompiling} = helpers


    ### ---------------- COMMANDS ------------------------------------------- ###
    # Bump the app version and tag
    @command
      cmd: 'bump [importance]'
      description: 'Increment version and tag repo. major|minor|patch|prerelease'
      action: (importance='minor') ->
        logger.warn "Bumping version: #{importance}"
        gulp.src ['./bower.json']
          .pipe logging()
          .pipe $.bump type:importance
          .pipe gulp.dest './'
          .pipe $.git.commit "bumps package version -- #{importance}"
          .pipe $.filter ['bower.json']
          .pipe $.tagVersion(prefix:'')


    ### ---------------- TASKS ---------------------------------------------- ###
    # Generate app manifest for offline mode
    @task 'apps:manifest', ->
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

    donee()
