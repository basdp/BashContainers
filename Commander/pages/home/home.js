'use strict';

var module = angular.module('Thinder.Commander.Controllers.Home', ['ngRoute']);

module.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/home', {
        templateUrl: 'pages/home/home.html',
        controller: 'HomeCtrl',
        activeTab: 'home'
    });
}]);

module.controller('HomeCtrl', ['$scope', function ($scope) {

}]);
