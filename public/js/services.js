'use strict';

angular.module('simplePvrServices', ['ngResource']).
factory('UpcomingRecording', function($resource) {
	return $resource('/upcoming_recordings/:id');
}).
factory('Schedule', function($resource) {
	return $resource('/schedules/:id', {id: '@id'});
}).
factory('Channel', function($resource) {
	return $resource('/channels/:id');
}).
factory('ProgrammeListing', function($resource) {
	return $resource('/channels/:channelId/programme_listings/:date');
}).
factory('Programme', function($resource) {
	return $resource('/programmes/:id');
}).
factory('Show', function($resource) {
	return $resource('/shows/:id', {id: '@id'});
}).
factory('Recording', function($resource) {
	return $resource('/shows/:showId/recordings/:recordingId', {showId: '@show_id', recordingId: '@id'});
}).
factory('Status', function($resource) {
	return $resource('/status');
});
