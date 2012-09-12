'use strict';

angular.module('simplePvrServices', ['ngResource']).
factory('UpcomingRecording', function($resource) {
	return $resource('/api/upcoming_recordings/:id');
}).
factory('Schedule', function($resource) {
	return $resource('/api/schedules/:id', {id: '@id'});
}).
factory('Channel', function($resource) {
	return $resource('/api/channels/:id', {id: '@id'});
}).
factory('ProgrammeListing', function($resource) {
	return $resource('/api/channels/:channelId/programme_listings/:date');
}).
factory('Programme', function($resource) {
	return $resource('/api/programmes/:id');
}).
factory('Show', function($resource) {
	return $resource('/api/shows/:id', {id: '@id'});
}).
factory('Recording', function($resource) {
	return $resource('/api/shows/:showId/recordings/:recordingId', {showId: '@show_id', recordingId: '@id'});
}).
factory('Status', function($resource) {
	return $resource('/api/status');
});
