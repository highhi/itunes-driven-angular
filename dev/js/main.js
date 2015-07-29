'use strict';

var angular = require('angular');
var ngResource = require('./angular-resource');
var ngRoute = require('./angular-route');
var app = angular.module('itunesDriven', ['ngResource', 'ngRoute']);

app.config(['$routeProvider', function($routeProvider){
	$routeProvider.when('/', {templateUrl : './list.html', controller : 'MainController'});
}])
.controller('MainController', ['$scope', '$http', '$sce', function ($scope, $http, $sce) {

	$scope.doSearch = function(){
		var term = encodeURIComponent($scope.term);
		var json = 'https://itunes.apple.com/search?term='+ term +'&media=music&country=jp&lang=ja_jp&callback=JSON_CALLBACK';

		$scope.itemIndex = -1;

		$http.jsonp(json).success(function(data) {
			var results = data.results;
			$scope.results = results;
		});
	};

	$scope.currentMusic = {
		id : -1,
		src : ''
	};

	$scope.sortItems = [
		{ label : 'Artist', value : 'artistName' },
		{ label : 'Track', value : 'trackName' },
		{ label : 'Collection', value : 'collectionName' },
		{ label : 'Collection Price', value : 'collectionPrice' }
	];

	$scope.selectedLabel = $scope.sortItems[0].value;

	$scope.trustSrc = function(src) {
		return $sce.trustAsResourceUrl(src);
	};

	$scope.onMusicButton = function(e, index){
		var src;

		if ( $scope.itemIndex === index ) {
			$scope.itemIndex = -1;
		} else {
			$scope.itemIndex = index;
		}

		if ( $scope.currentMusic.id === index ) {
			src = '//：0';
		} else {
			src = this.result.previewUrl;
		}

		$scope.currentMusic.src = src;
		$scope.currentMusic.id = index;
	};

}]);