
module.exports =
  name: 'recipe-vendor'
  attach: ->
    @register
      name:   'vendor'
      ext:    'vendor'
      type:   'vendor'
      doc:    false
      test:   true
      lint:   false
      reload: true
