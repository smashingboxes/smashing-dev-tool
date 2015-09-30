"use strict"

app = angular.module("swag2", [
  "ngRoute"
  "ngSanitize"
  "swaggerUi"
])

app.run (swaggerModules, swaggerUiExternalReferences) ->
  swaggerModules.add(swaggerModules.BEFORE_PARSE, swaggerUiExternalReferences)

app.config ($routeProvider) ->
  $routeProvider
    .when "/",
      templateUrl:         "main/main.html"
      controller:          "MainCtrl"
    .otherwise redirectTo: "/"
