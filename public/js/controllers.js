'use strict';

function SchedulesCtrl($scope, Schedule, UpcomingRecording, Channel) {
	var updateView = function() {
		$scope.schedules = Schedule.query();
		$scope.upcomingRecordings = UpcomingRecording.query();
		$scope.newSchedule = { title: null, channelId: 0 }
	}

	$scope.channels = Channel.query();
	updateView();
	
	$scope.createSchedule = function() {
		var schedule = new Schedule({ title: $scope.newSchedule.title, channel_id: $scope.newSchedule.channelId })
		schedule.$save(updateView);
	}
	
	$scope.deleteSchedule = function(schedule) {
		schedule.$delete(updateView);
	}
}

function ChannelsCtrl($scope, Channel) {
	$scope.channels = Channel.query();
}

function ProgrammeListingCtrl($scope, $routeParams, ProgrammeListing) {
	$scope.channelId = $routeParams.channelId;
	$scope.date = $routeParams.date;
	
	$scope.programmeListing = ProgrammeListing.get({channelId: $scope.channelId, date: $scope.date});
}

function ProgrammeCtrl($scope, $routeParams, $http, Programme) {
	var loadProgramme = function() {
		$scope.programme = Programme.get({id: $routeParams.programmeId})
	}
	var post = function(url) {
		$http.post(url).success(loadProgramme);
	}
	
	$scope.recordOnThisChannel = function() {
		post('/programmes/' + $scope.programme.id + '/record_on_this_channel');
	}
	$scope.recordOnAnyChannel = function() {
		post('/programmes/' + $scope.programme.id + '/record_on_any_channel');
	}
	
	loadProgramme();
}

function ShowsCtrl($scope, $http, Show) {
	var loadShows = function() {
		$scope.shows = Show.query();
	}
	
	$scope.deleteEpisodes = function(show) {
		show.$delete(loadShows);
	}
	
	loadShows();
}

function ShowCtrl($scope, $routeParams, Show, Recording) {
	var loadRecordings = function() {
		$scope.recordings = Recording.query({showId: $routeParams.showId});
	}
	
	$scope.deleteRecording = function(recording) {
		recording.$delete(loadRecordings);
	}

	$scope.show = Show.get({id: $routeParams.showId});
	loadRecordings();
}

function StatusCtrl($scope, Status) {
	$scope.status = Status.get();
}