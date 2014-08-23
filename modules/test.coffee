fs =              require 'fs'
open =            require 'open'
gulp =            require 'gulp'                  # streaming build system



module.exports = ({assets, tasks, args, dir, env, pkg, util, helpers, commander}) ->
  {files, vendorFiles, copyFiles, time, filters, dest, colors} = helpers
  {logger, notify, execute, $} = util
