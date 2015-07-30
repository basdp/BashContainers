'use strict';

var module = angular.module('Thinder.Commander.Directives');

module.directive('thinderCommanderVersion', ['version', function (version) {
    return function (scope, elm, attrs) {
        elm.text(version);
    };
}]);
