define [
  'app'
], (app) ->

  app.register.controller 'homeController', [
    '$scope'
    '$window'
    '$rootScope'
    '$timeout'
    ($scope, $window, $rootScope, $timeout) ->
      console.log 'WE ARE HOME!'
  ]
