# smasher  = require '../config/global'
#
# {commander, assumptions, rootPath, user, platform, project, helpers, util} = smasher
# {logger, notify, execute, merge, args} = util
# {files, dest, $, logging, watching, caching, banner, plumbing, stopPlumbing, onError} = helpers

module.exports =
  name: 'recipe-fonts'
  attach: ->
    @register
      name:        'fonts'
      ext:         ['eot', 'svg', 'ttf', 'woff']
      type:        'data'
      doc:         false
      test:        true
      lint:        false
      reload:      true
      passThrough: true
      path:        "data/fonts"
