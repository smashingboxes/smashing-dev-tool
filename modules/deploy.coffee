

module.exports = (project) ->
  {assets, tasks, args, dir, env, pkg, util, helpers, commander} = project
  {files, compiledFiles, vendorFiles, copyFiles, time, filters, dest, colors, $, banner} = helpers
  {logger, notify, execute} = util

  # require ('../phases/deploy')(project)
