"use strict"

app = angular.module('<%= appNameSlug %>', [
  "ngRoute"
  "ngMaterial"
]).config(($routeProvider, $mdThemingProvider) ->

  $mdThemingProvider.theme('default')
    .primaryPalette('pink')
    .accentPalette('green')

  $routeProvider
    .when "/",
      templateUrl:         "main/main.html"
      controller:          "MainCtrl"
    .otherwise redirectTo: "/"
)
