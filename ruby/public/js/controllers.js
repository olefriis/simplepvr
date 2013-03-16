'use strict';

function SchedulesCtrl($scope, $http, Schedule, UpcomingRecording, Channel) {
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
	
	$scope.excludeRecording = function(recording) {
		$http.post('/api/programmes/' + recording.programme_id + '/exclude').success(updateView);
	}
}

function ScheduleCtrl($scope, $routeParams, $location, Schedule, Channel) {
	$scope.channels = Channel.query(function() {
		$scope.schedule = Schedule.get({id: $routeParams.scheduleId}, function() {
			for (var i=0; i<$scope.channels.length; i++) {
				var channel = $scope.channels[i]
				if ($scope.schedule.channel && channel.id === $scope.schedule.channel.id) {
					$scope.channel = channel;
				}
			}
		});
	});
	
	$scope.update = function() {
		$scope.schedule.channel = $scope.channel;
		$scope.schedule.$save(function() { $location.path('/schedules'); });
	}
}

function ChannelsCtrl($scope, $http, Channel) {
	$scope.channels = Channel.query();
	$scope.showHiddenChannels = false;
	
	$scope.classForProgrammeLine = function(programme) {
		if (programme == null) {
			return '';
		}
		return programme.is_conflicting ? 'error' : (programme.is_scheduled ? 'success' : '');
	}
	$scope.hideChannel = function(channel) {
		// I wish Angular could let me define this operation on the Channel object
		$http.post('/api/channels/' + channel.id + '/hide').success(function() { channel.$get(); });
	}
	$scope.showChannel = function(channel) {
		// I wish Angular could let me define this operation on the Channel object
		$http.post('/api/channels/' + channel.id + '/show').success(function() { channel.$get(); });
	}
	$scope.shouldShowChannel = function(channel) {
		return $scope.showHiddenChannels || !channel.hidden;
	}
}

function ProgrammeListingCtrl($scope, $routeParams, ProgrammeListing) {
	$scope.channelId = $routeParams.channelId;
	$scope.date = $routeParams.date;
	$scope.programmeListing = ProgrammeListing.get({channelId: $scope.channelId, date: $scope.date});
	
	$scope.classForProgrammeLine = function(programme) {
		return programme.is_conflicting ? 'error' : (programme.is_scheduled ? 'success' : '');
	}
}

function ProgrammeCtrl($scope, $routeParams, $http, Programme) {
	var loadProgramme = function() {
		$scope.programme = Programme.get({id: $routeParams.programmeId});
	}
	var post = function(url) {
		$http.post(url).success(loadProgramme);
	}
	
	$scope.recordOnThisChannel = function() {
		// I wish Angular could let me define this operation on the Programme object
		post('/api/programmes/' + $scope.programme.id + '/record_on_this_channel');
	}
	$scope.recordOnAnyChannel = function() {
		// I wish Angular could let me define this operation on the Programme object
		post('/api/programmes/' + $scope.programme.id + '/record_on_any_channel');
	}
	$scope.recordJustThisProgramme = function() {
		// I wish Angular could let me define this operation on the Programme object
		post('/api/programmes/' + $scope.programme.id + '/record_just_this_programme');
	}

	loadProgramme();
}

function ShowsCtrl($scope, $http, Show) {
	var loadShows = function() {
		$scope.shows = Show.query();
	}
	
	$scope.deleteEpisodes = function(show) {
		if (confirm("Really delete all episodes of\n" + show.name + "\n?")) {
			show.$delete(loadShows);
		}
	}
	
	loadShows();
}

function ShowCtrl($scope, $routeParams, $http, Show, Recording) {
	var loadRecordings = function() {
		$scope.recordings = Recording.query({showId: $routeParams.showId});
	}
	
	$scope.deleteRecording = function(recording) {
		if (confirm("Really delete recording\n" + recording.episode + "\nof show\n" + $scope.show.name + "\n?")) {
			recording.$delete(loadRecordings);
		}
	}

	$scope.startTranscoding = function(recording) {
		// I wish Angular could let me define this operation on the Programme object
		$http.post('/api/shows/' + $routeParams.showId + '/recordings/' + recording.id + '/transcode').success(loadRecordings);
	}

	$scope.show = Show.get({id: $routeParams.showId});
	loadRecordings();
}

function SearchProgrammesCtrl($scope, $http, $location) {
	$scope.autocomplete = function(query, process) {
		$http.get('/api/programmes/title_search', {params: {query: query}}).success(process);
	}

	$scope.updater = function(item) {
		$scope.$apply(function() {
			$scope.title = item;
		});
		return item;
	}
	
	$scope.search = function() {
		$location.path('/search').search({query: $scope.title});
	}
}

function SearchCtrl($scope, $routeParams, $http) {
	$scope.query = $routeParams.query;
	$http.get('/api/programmes/search', {params: {query: $scope.query}}).success(function(result) {
		$scope.result = result;
	});
}

function StatusCtrl($scope, Status) {
	$scope.status = Status.get();
}