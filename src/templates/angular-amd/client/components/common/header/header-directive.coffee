define [
  'app'
], (app) ->

  app.register.directive 'header', ->
    restrict: 'EA'
    replace: true
    templateUrl: 'components/common/header/header.html'
    controller: [
      '$scope'
      '$window'
      '$rootScope'
      '$timeout'
      ($scope, $window, $rootScope, $timeout) ->
        console.log 'HEADER DIRECTIVE REPORTING FOR DUTY'
    ]
