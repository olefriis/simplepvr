'use strict';

angular.module('simplePvr', ['simplePvrServices']).
directive('pvrAutocomplete', function() {
	return function(scope, element, attrs) {
		element.typeahead({
			source: scope.autocomplete
		});
	}
}).
filter('chunk', function() {
  function chunkArray(array, chunkSize) {
    var result = [];
	var currentChunk = [];
	for (var i=0; i<array.length; i++) {
		currentChunk.push(array[i]);
		if (currentChunk.length == chunkSize) {
			result.push(currentChunk);
			currentChunk = [];
		}
	}
	if (currentChunk.length > 0) {
		result.push(currentChunk);
	}
	return result;
  }

  function defineHashKeys(array) {
	for (var i=0; i<array.length; i++) {
		array[i].$$hashKey = i;
	}
  }

  return function(array, chunkSize) {
	if (!(array instanceof Array)) return array;
	if (!chunkSize) return array;
	var result = chunkArray(array, chunkSize);
	defineHashKeys(result);
	return result;
  }
}).
config(function($routeProvider, $locationProvider) {
    $locationProvider.html5Mode(true).hashPrefix('');

	$routeProvider.
	when('/schedules', {
		templateUrl: '/app/partials/schedules.html',
		controller: SchedulesCtrl
	}).
	when('/channels', {
		templateUrl: '/app/partials/channels.html',
		controller: ChannelsCtrl
	}).
	when('/channels/:channelId/programmeListings/:date', {
		templateUrl: '/app/partials/programmeListing.html',
		controller: ProgrammeListingCtrl
	}).
	when('/programmes/:programmeId', {
		templateUrl: '/app/partials/programme.html',
		controller: ProgrammeCtrl
	}).
	when('/shows', {
		templateUrl: '/app/partials/shows.html',
		controller: ShowsCtrl
	}).
	when('/shows/:showId', {
		templateUrl: '/app/partials/show.html',
		controller: ShowCtrl
	}).
	when('/search', {
		templateUrl: '/app/partials/search.html',
		controller: SearchCtrl
	}).
	when('/status', {
		templateUrl: '/app/partials/status.html',
		controller: StatusCtrl
	}).
	when('/about', {
		templateUrl: '/app/partials/about.html'
	}).
	otherwise({
		redirectTo: '/schedules'
	});
});
