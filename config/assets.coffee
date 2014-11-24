assets    = [
  {
    name:   'html'
    ext:    'html'
    type:   'view'
    doc:    true
    test:   true
    lint:   true
    reload: true
  }
  {
    name:   'jade'
    ext:    'jade'
    type:   'view'
    doc:    true
    test:   true
    lint:   false
    reload: true
  }
  {
    name:   'css'
    ext:    'css'
    type:   'style'
    doc:    true
    test:   true
    lint:   true
    reload: false
  }
  {
    name:   'stylus'
    ext:    'styl'
    type:   'style'
    doc:    false
    test:   false
    lint:   false
    reload: false
  }
  {
    name:   'js'
    ext:    'js'
    type:   'script'
    doc:    true
    test:   true
    lint:   true
    reload: true
  }
  {
    name:   'coffeescript'
    ext:    'coffee'
    type:   'script'
    doc:    true
    test:   true
    lint:   true
    reload: true
  }
  {
    name:   'json'
    ext:    'json'
    type:   'data'
    doc:    false
    test:   true
    lint:   true
    reload: true
  }
  {
    name:   'images'
    ext:    'images'
    type:   'data'
    doc:    false
    test:   true
    lint:   false
    reload: true
  }
  {
    name:   'fonts'
    ext:    'fonts'
    type:   'data'
    doc:    false
    test:   true
    lint:   false
    reload: true
  }
]


eAssets = []
for a in assets
  eAssets[a.ext] = a
module.exports = eAssets
