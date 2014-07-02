fs =              require 'fs'
path =            require 'path'
exec =            require('child_process').exec
async =           require 'async'
through =         require 'through2'
{PluginError} =   require 'gulp-util'
{log} =           require 'gulp-util'

base = require.main.filename
baseDir = base.replace(base.substr(base.indexOf 'node_modules'), '')

createPluginError = (message) ->
  new PluginError 'gulp-groc', message

gulpGroc = (appId) ->

  through.obj (file, enc, done) ->
    if file.isNull()
      @push file
      done()

    if file.isStream()
      @emit 'error', createPluginError('stream content is not supported')

    console.log file.path

    done()

module.exports = gulpGroc
