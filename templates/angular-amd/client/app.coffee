define [
  'angularAMD'
  'angular-route'
  'angular-animate'
], (angularAMD) ->
  app = angular.module('sb-app', ['ngRoute', 'ngAnimate'])

  # Configure Angular ngApp with route and cache the needed providers
  app.config ['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
    # $locationProvider.html5Mode true
    $routeProvider.when('/', angularAMD.route(
      templateUrl: 'home/home.html'
      controller: 'homeController'
    )).otherwise redirectTo: '/'

    $routeProvider.when('/about', angularAMD.route(
      templateUrl: 'about/about.html'
      controller: 'aboutController'
    )).otherwise redirectTo: '/'
  ]

  # Define constant to be used by Google Analytics
  app.constant 'SiteName', 'sb-app'

  # Bootstrap Angular when DOM is ready
  angularAMD.bootstrap app
  app
