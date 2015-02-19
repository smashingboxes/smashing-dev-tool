###
Base Smashfile

This serves as the basis for creating per-project smashfiles. These settings
represent the default config for a given version of this tool, and are merged
with the contents of the smashfile for a given project at runtime.
###

# TODO: create per-template smashfiles that can be used as a base config starting point
# for projects generated from those templates as well as other projects on the system
#   EX:  `base: 'angular-simple'`


module.exports =
  # --- Per-project Smashfiles can't override: ---
  supportedAssets: ['js', 'coffee', 'css', 'styl', 'scss', 'html', 'jade', 'json']


  # --------------------- Config
  # banner: ""

  # Client-side code
  client:
    path: 'client'

  # Server-side code
  server:
    path: 'server'

  # 3rd-party libraries
  vendor:
    path: 'client/components/vendor'

  images:
    path: 'data/images'

  fonts:
    path: 'data/fonts'


  # File types to handle for a project
  assets: [ ]


  # --------------------- Phases
  # Testing
  test:
    prefix: 'test_'


  # Compile phase
  compile:
    path:        'compile'
    html2js:     true
    css2js:      true
    skipPlugins: []
    exclude:     []

    styles:      {}
    views:       {}
    scripts:     {}
    images:      {}
    fonts:       {}


  # Build Phase
  build:
    path:          'build'
    html2js:       true
    css2js:        true
    skipPlugins:   []
    exclude:       []
    includeIndex:  true
    includeVendor: true

    styles:
      out: 'app-styles.min.css'
      order: [ ]
    views:
      out: 'app-views.min.js'
      order: [ ]
    scripts:
      out: 'app.min.js'
      order: [
        '**/jquery.js'
        '**/*jquery*.*'
        '**/angular.js'
        '**/*angular*.*.js'
        'components/vendor/**/*.js'
        'app.js'
      ]

    alternates: [ ]


  # Deploy Phase
  deploy:
    path: 'deploy'


  # Documentation
  docs:
    path: 'docs'
