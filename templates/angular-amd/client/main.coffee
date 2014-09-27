require.config
  baseUrl: ''

  # alias libraries paths
  paths:
    ngload:              'ngload'

    homeController:      'home/home-controller'
    aboutController:      'about/about-controller'

  # Add angular modules that does not support
  # AMD out of the box, put it in a shim
  shim:
    angularAMD:             ['angular']
    'angular-route':        ['angular']
    'angular-animate':      ['angular']
    'underscore':           'exports': '_'
  priority: ['angular']

  # kick start application
  deps: ['app']
