fs =              require 'fs'
path =            require 'path'
exec =            require('child_process').exec
through =         require 'through2'
util =            require 'gulp-util'
notifier =        require('node-notifier')
{PluginError} = util

createPluginError = (message) ->
  new PluginError 'gulp-stackato-sync', message


n = new notifier()


cache = []
gulpStackatoSync = (appId, appName) ->
  notify = (message) ->
    n.notify
      title: "scp-sync || #{appName}"
      message: message
      group: 'app-scp'

  log = (msg) ->
    b = util.colors.styles.blue
    util.log  '[' + b.open + 'scp-sync' + b.close + ']', msg

  through.obj (file, enc, done) ->
    if file.isNull()
      @push file
      done()

    if file.isStream()
      @emit 'error', createPluginError('stream content is not supported')


    unless cache[file.path]?
      cache[file.path] = true
      done()
    else

      dir = __dirname.replace 'config/plugins', 'compile/'
      dest = file.path.replace dir, ''

      u = util.colors.styles.underline
      log "Updating " + u.open + dest + u.close
      notify "Updating " + dest.split('/').pop()
      exec "stackato scp #{appId} #{file.path} :#{dest}", (err, stdout, stderr) ->
        if err
          log util.colors.red "✘ #{u.open}#{dest}#{u.close}# failed to upload"
          notify "ERROR:" + dest.split('/').pop()
          done()
        else
          log util.colors.green "✔ #{u.open}#{dest}#{u.close} uploaded successfully"
          notify dest.split('/').pop() + " updated!"
          done()

module.exports = gulpStackatoSync
