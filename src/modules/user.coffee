
module.exports =
  name: 'user'
  attach: (options) ->
    gitConfig = require('git-config').sync()
    user = gitConfig.user or {}
    user.homeDir =  process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE
    user.username = if gitConfig.github?.user? then gitConfig.github.user else user.homeDir?.split("/").pop() or 'root'

    @user = user
