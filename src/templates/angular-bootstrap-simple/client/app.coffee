"use strict"

app = angular.module("<%= appNameSlug %>", [
  "ngRoute"
]).config(($routeProvider) ->

  $routeProvider
    .when "/",
      templateUrl:         "main/main.html"
      controller:          "MainCtrl"
    .otherwise redirectTo: "/"
)
