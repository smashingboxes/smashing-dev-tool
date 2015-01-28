
os           = require 'os'

module.exports =
  name: 'platform'
  attach: (options) ->
    @platform =
      type:               os.type()
      platform:           os.platform()
      hostname:           os.hostname()
      arch:               os.arch()
      release:            os.release()
      EOL:                os.EOL
      cpus:               os.cpus()
      networkInterfaces:  os.networkInterfaces()
