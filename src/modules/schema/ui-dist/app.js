/** 
 * sb-swagger-ui  
 * v. 0.1.0  
 * 
 * Built Wednesday, September 30th 2015, 12:54am  
 */ 

"use strict";
var app;

app = angular.module("swag2", ["ngRoute", "ngSanitize", "swaggerUi"]);

app.run(function(swaggerModules, swaggerUiExternalReferences) {
  return swaggerModules.add(swaggerModules.BEFORE_PARSE, swaggerUiExternalReferences);
});

app.config(function($routeProvider) {
  return $routeProvider.when("/", {
    templateUrl: "main/main.html",
    controller: "MainCtrl"
  }).otherwise({
    redirectTo: "/"
  });
});
