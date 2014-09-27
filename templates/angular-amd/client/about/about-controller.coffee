define [
  'app'
  '../components/common/header/header-directive.js'
  '../components/common/header/main-nav-directive.js'
], (app) ->

  app.register.controller 'aboutController', [
    '$scope'
    '$window'
    '$rootScope'
    '$timeout'
    ($scope, $window, $rootScope, $timeout) ->
      console.log 'WE ARE HOME!'
  ]
