define [
  'angularAMD'
  'angular-route'
  'angular-animate'
  'modernizr'
  'bower-foundation'
], (angularAMD) ->
  app = angular.module('bodybar', ['ngRoute', 'ngAnimate'])

  # Configure Angular ngApp with route and cache the needed providers
  app.config ['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
    $(document).foundation()

    $locationProvider.html5Mode true

    $routeProvider.when('/', angularAMD.route(
      templateUrl: 'pages/home.html'
      controller: 'HomeCtrl'
    )).otherwise redirectTo: '/'
  ]

  # Define constant to be used by Google Analytics
  app.constant 'SiteName', 'soundbar'

  # Bootstrap Angular when DOM is ready
  angularAMD.bootstrap app
  app
