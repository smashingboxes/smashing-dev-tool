'use strict'

angular.module('swag2')
  .controller 'MainCtrl', ($scope, Settings) ->
    $scope.schemaUrl = "http://localhost:3100/api-docs"
