
os     = require 'os'

module.exports = (Registry) ->  
  platform =
    type:               os.type()
    platform:           os.platform()
    hostname:           os.hostname()
    arch:               os.arch()
    release:            os.release()
    EOL:                os.EOL
    cpus:               os.cpus()
    networkInterfaces:  os.networkInterfaces()

  Registry.register 'platform', platform,
    type: 'static'
