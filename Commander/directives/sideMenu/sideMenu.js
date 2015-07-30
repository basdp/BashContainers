'use strict';

var module = angular.module('Thinder.Commander.Directives');

module.directive('commanderSideMenu', [function () {
    return {
        restrict: 'E',
        transclude: true,
        scope: {},
        templateUrl: 'directives/sideMenu/sideMenu.html'
    };
}]);

module.directive('commanderSideMenuItem', [function () {
    return {
        require: '^commanderSideMenu',
        restrict: 'E',
        scope: {
            caption: '@',
            icon: '@',
            url: '@'
        },
        templateUrl: 'directives/sideMenu/sideMenuItem.html',
        controller: ['$scope', '$route', function($scope, $route) {
            $scope.$route = $route;
        }]
    };
}]);
