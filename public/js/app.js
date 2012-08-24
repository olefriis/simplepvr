'use strict';

angular.module('simplePvr', ['simplePvrServices']).
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
