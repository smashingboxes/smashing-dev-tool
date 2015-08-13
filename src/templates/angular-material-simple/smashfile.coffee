module.exports =
  generator: 'angular-material-simple'
  
  assets: [
    'coffee'
    'jade'
    'styl'
  ]

  build:
    path:          'pkg'
    html2js:       true
    css2js:        true
    includeIndex:  true
    includeVendor: true

    styles:
      order: [
        'app.css'
        '**/*.css'
      ]

    scripts:
      order: [
        '**/jquery.js'
        '**/*jquery*.*'
        '**/angular.js'
        '**/*angular*.*.js'
        'components/vendor/**/*.js'
        'app.js'
      ]
