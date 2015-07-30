'use strict';

var module = angular.module('Thinder.Commander', [
    'ngRoute',
    'Thinder.Commander.Directives',
    'Thinder.Commander.Controllers.Home',
]);

angular.module('Thinder.Commander.Directives', []);
angular.module('Thinder.Commander.Services', []);
angular.module('Thinder.Commander.Controllers', []);

module.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.otherwise({redirectTo: '/home'});
}]);


module.value('version', '0.1');

module.controller('AppCtrl', ['$scope', '$location', '$route', function ($scope, $location, $route) {
    $scope.navigateTo = function(url) {
        $location.url(url);
    };
}]);
