
module.exports = (Registry) ->
  gitConfig = require('git-config').sync()

  user = gitConfig.user or {}
  user.git = gitConfig
  user.homeDir =  process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE
  user.username = if gitConfig.github?.user? then gitConfig.github.user else user.homeDir?.split("/").pop() or 'root'
  
  Registry.register 'user', user,
    type: 'static'
