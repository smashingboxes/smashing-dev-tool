
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
