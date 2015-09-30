/** 
 * sb-swagger-ui  
 * v. 0.1.0  
 * 
 * Built Wednesday, September 30th 2015, 12:54am  
 */ 

'use strict';
angular.module('swag2').controller('MainCtrl', function($scope, Settings) {
  return $scope.schemaUrl = "http://localhost:3100/api-docs";
});
