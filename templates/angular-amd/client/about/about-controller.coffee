define [
  'app'
], (app) ->

  app.register.controller 'aboutController', [
    '$scope'
    '$window'
    '$rootScope'
    '$timeout'
    ($scope, $window, $rootScope, $timeout) ->
      console.log 'WE ARE HOME!'
  ]
