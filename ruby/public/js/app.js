'use strict';

angular.module('simplePvr', ['simplePvrServices']).
directive('pvrAutocomplete', function() {
	return function(scope, element, attrs) {
		element.typeahead({
			source: scope.autocomplete
		});
	}
}).
directive('navbarItem', function($location) {
	return {
		template: '<li><a ng-href="{{route}}" ng-transclude></a></li>',
		restrict: 'E',
		transclude: true,
		replace: true,
		scope: { route:'@route' },
		link: function(scope, element, attributes, controller) {
			scope.$on('$routeChangeSuccess', function() {
				var path = $location.path();
				var isSamePath = path == scope.route;
				var isSubpath = path.indexOf(scope.route + '/') == 0;
				if (isSamePath || isSubpath) {
					element.addClass('active');
				} else {
					element.removeClass('active');
				}
			});
		}
	};
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
filter('formatEpisode', function() {
    return function(episodeNum) {
        return episodeNum ? episodeNum.replace(' .', '').replace('. ', '') : "";
    }
}).
filter('filteredWeekdays', function() {
	return function(schedule) {
		if (!schedule.filter_by_weekday) {
			return '';
		}
		
		var selectedWeekdays = [];
		if (schedule.monday) selectedWeekdays.push('Mondays');
		if (schedule.tuesday) selectedWeekdays.push('Tuesdays');
		if (schedule.wednesday) selectedWeekdays.push('Wednesdays');
		if (schedule.thursday) selectedWeekdays.push('Thursdays');
		if (schedule.friday) selectedWeekdays.push('Fridays');
		if (schedule.saturday) selectedWeekdays.push('Saturdays');
		if (schedule.sunday) selectedWeekdays.push('Sundays');

		var days = '';
		if (selectedWeekdays.length == 0) {
			return ''
		} else if (selectedWeekdays.length == 1) {
			days = selectedWeekdays[0];
		} else if (selectedWeekdays.length == 2) {
			days = selectedWeekdays[0] + ' and ' + selectedWeekdays[1];
		} else {
			for (var i=0; i<selectedWeekdays.length - 1; i++) {
				days += selectedWeekdays[i] + ', ';
			}
			days += 'and ' + selectedWeekdays[selectedWeekdays.length - 1];
		}
		return '(' + days + ')';
	}
}).
config(function($routeProvider, $locationProvider) {
    $locationProvider.html5Mode(true).hashPrefix('');

	$routeProvider.
	when('/schedules', {
		templateUrl: '/app/partials/schedules.html',
		controller: SchedulesCtrl
	}).
	when('/schedules/:scheduleId', {
		templateUrl: '/app/partials/schedule.html',
		controller: ScheduleCtrl
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