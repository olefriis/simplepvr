'use strict';

angular.module('simplePvr', ['simplePvrServices']).
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
		templateUrl: 'partials/schedules.html',
		controller: SchedulesCtrl
	}).
	when('/channels', {
		templateUrl: 'partials/channels.html',
		controller: ChannelsCtrl
	}).
	when('/channels/:channelId/programmeListings/:date', {
		templateUrl: 'partials/programmeListing.html',
		controller: ProgrammeListingCtrl
	}).
	when('/programmes/:programmeId', {
		templateUrl: 'partials/programme.html',
		controller: ProgrammeCtrl
	}).
	when('/shows', {
		templateUrl: 'partials/shows.html',
		controller: ShowsCtrl
	}).
	when('/shows/:showId', {
		templateUrl: 'partials/show.html',
		controller: ShowCtrl
	}).
	when('/status', {
		templateUrl: 'partials/status.html',
		controller: StatusCtrl
	}).
	when('/about', {
		templateUrl: 'partials/about.html'
	}).
	otherwise({
		redirectTo: '/schedules'
	});
}]);
