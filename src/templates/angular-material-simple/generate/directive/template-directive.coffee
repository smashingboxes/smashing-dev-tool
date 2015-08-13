'use strict'

angular.module('<%= appName %>')
  .directive '<%= name %>', ($document) ->
    restrict: "E"
    templateUrl: '<%= templatePath %>/<%= nameSlug %>.html'
    controller: ($scope)->
    link: (scope, element, attributes) ->
