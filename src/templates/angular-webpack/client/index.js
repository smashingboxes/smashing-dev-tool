var jquery = require('jquery');
var angular = require('./lib/angular');


var myApp = angular.module('myApp', []);
myApp.controller('mainCtrl', require('./js/mainCtrl'));
