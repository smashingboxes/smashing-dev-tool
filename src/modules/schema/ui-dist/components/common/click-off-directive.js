/** 
 * sb-swagger-ui  
 * v. 0.1.0  
 * 
 * Built Wednesday, September 30th 2015, 12:54am  
 */ 

'use strict';
angular.module('swag2').directive('clickOff', function($document) {
  return {
    restrict: "A",
    link: function(scope, element, attributes) {
      var justOpened;
      justOpened = false;
      element.bind('click', function(e) {
        return justOpened = true;
      });
      return $document.bind('click', function() {
        if (!justOpened) {
          scope.$apply(attributes.clickOff);
        }
        return justOpened = false;
      });
    }
  };
});
