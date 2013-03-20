'use strict';

angular.module('simplePvr', ['simplePvrServices', 'simplePvrFilters']).
directive('titleSearch', function() {
	return {
		templateUrl: '/app/templates/titleSearch.html',
		restrict: 'E',
		replace: true,
		controller: SearchProgrammesCtrl,
		link: function(scope, element, attributes, controller) {
			element.find('input').typeahead({
				source: scope.autocomplete,
				updater: scope.updater
			});
		}
	};
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
