# Bootstrap Angular when DOM is ready
define ['app', 'angularAMD'], (app, angularAMD) ->
  angularAMD.bootstrap app
  app
