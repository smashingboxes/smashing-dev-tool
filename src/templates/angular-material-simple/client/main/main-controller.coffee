'use strict'

angular.module('<%= appNameSlug %>')
  .controller 'MainCtrl', ($scope, Settings) ->
    console.log 'main controller!'

    $scope.features = [
      {
        name: 'Angular Material',
        description: 'A port of Google\'s Material Design to Angular'
        url: 'https://material.angularjs.org/'
      }
      {
        name: 'AngularRoute'
        description: 'SPA routing for Angular'
        url:'https://github.com/angular/bower-angular-route'
      }
      {
        name: 'Ionicons'
        description: 'Ionic\'s minimal icon library'
        url: 'http://ionicons.com/'
      }
      {
        name: 'lodash'
        description: 'A functional programming toolbelt'
        url: 'https://lodash.com/'
      }
      {
        name: 'jQuery'
        description: 'DOM manipulation library'
        url: 'http://jquery.com/'
      }
    ]
