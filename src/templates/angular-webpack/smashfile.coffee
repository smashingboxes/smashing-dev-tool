module.exports =
  assets: [
    'js'
    'html'
    'css'
  ]

  build:
    css2js: false
    html2js: false


  webpack:
    # context: "#{__dirname}/client"
    cache: true
    entry: 'index'
    output:
      path: "#{__dirname}/dist"
      filename: 'browser-bundle.js'
    module:
      loaders: []
