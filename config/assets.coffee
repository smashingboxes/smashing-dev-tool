assets = [
  {
    name: 'html'
    ext:  'html'
    type: 'view'
    doc: true
    test: true
    lint: true
  }
  {
    name: 'jade'
    ext:  'jade'
    type: 'view'
    doc: true
    test: true
    lint: false
  }
  {
    name: 'css'
    ext:  'css'
    type: 'style'
    doc: true
    test: true
    lint: true
  }
  {
    name: 'stylus'
    ext:  'styl'
    type: 'style'
    doc: false
    test: false
    lint: false
  }
  {
    name: 'js'
    ext:  'js'
    type: 'script'
    doc: true
    test: true
    lint: true
  }
  {
    name: 'coffeescript'
    ext:  'coffee'
    type: 'script'
    doc: true
    test: true
    lint: true
  }
  {
    name: 'json'
    ext: 'json'
    type: 'data'
    doc: false
    test: true
    lint: true
  }
]


eAssets = []
for a in assets
  eAssets[a.ext] = a
module.exports = eAssets
