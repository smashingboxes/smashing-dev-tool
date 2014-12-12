define [
  'app'
], (app) ->

  app.register.directive 'mainNav', ->
    restrict: 'EA'
    replace: true
    templateUrl: 'components/common/main-nav/main-nav.html'
    controller: [
      '$scope'
      '$window'
      '$rootScope'
      '$timeout'
      ($scope, $window, $rootScope, $timeout) ->
        console.log 'MAIN NAV DIRECTIVE REPORTING FOR DUTY'
    ]
