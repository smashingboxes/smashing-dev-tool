require.config
  baseUrl: 'js'

  # alias libraries paths
  paths:
    ngload:                 'ngload'
    HomeCtrl:               'controllers/homeCtrl'

  # Add angular modules that does not support
  # AMD out of the box, put it in a shim
  shim:
    angularAMD:             ['angular', 'jquery']
    'angular-route':        ['angular']
    'angular-animate':      ['angular']
    'bower-foundation':     ['jquery', 'modernizr']
    'underscore':   'exports': '_'
  priority: ['angular']

  # kick start application
  deps: ['app']
