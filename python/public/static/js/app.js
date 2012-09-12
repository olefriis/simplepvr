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
config(['$routeProvider', function($routeProvider) {
	$routeProvider.
	when('/schedules', {
		templateUrl: 'static/partials/schedules.html',
		controller: SchedulesCtrl
	}).
	when('/channels', {
		templateUrl: 'static/partials/channels.html',
		controller: ChannelsCtrl
	}).
	when('/channels/:channelId/programmeListings/:date', {
		templateUrl: 'static/partials/programmeListing.html',
		controller: ProgrammeListingCtrl
	}).
	when('/programmes/:programmeId', {
		templateUrl: 'static/partials/programme.html',
		controller: ProgrammeCtrl
	}).
	when('/shows', {
		templateUrl: 'static/partials/shows.html',
		controller: ShowsCtrl
	}).
	when('/shows/:showId', {
		templateUrl: 'static/partials/show.html',
		controller: ShowCtrl
	}).
	when('/search', {
		templateUrl: 'static/partials/search.html',
		controller: SearchCtrl
	}).
	when('/status', {
		templateUrl: 'static/partials/status.html',
		controller: StatusCtrl
	}).
	when('/about', {
		templateUrl: 'static/partials/about.html'
	}).
	otherwise({
		redirectTo: '/schedules'
	});
}]);
