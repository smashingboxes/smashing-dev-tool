module.exports =
  assets: [
    'coffee'
    'jade'
    'styl'
    'css'
  ]
  compile:
    # path: "#{process.cwd()}/../ui"
    scripts:
      order: [
        '**/jquery.js'
        '**/*jquery*.*'
        '**/angular.js'
        '**/*angular*.*.js'
        'components/vendor/**/*.js'
        'app.js'
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
        '**/swagger-ui.min*'
        '**/*angular*.*.js'
        'components/vendor/**/*.js'
        'app.js'
      ]
