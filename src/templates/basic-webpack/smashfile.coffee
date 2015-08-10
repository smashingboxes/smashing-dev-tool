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
    entry: './entry.js'
    output:
      path: __dirname,
      filename: 'bundle.js'

    module:
      loaders: [
        { test: /\.css$/, loader: 'style!css' }
      ]
