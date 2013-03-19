'use strict';

angular.module('simplePvrFilters', []).
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
        return episodeNum ? episodeNum.replace(' .', '').replace('. ', '') : '';
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
filter('timeOfDay', function() {
	return function(schedule) {
		if (!schedule.filter_by_time_of_day) {
			return '';
		}
		if (schedule.from_time_of_day && schedule.to_time_of_day) {
			return '(between ' + schedule.from_time_of_day + ' and ' + schedule.to_time_of_day + ')';
		}
		if (schedule.from_time_of_day) {
			return '(after ' + schedule.from_time_of_day + ')';
		}
		if (schedule.to_time_of_day) {
			return '(before ' + schedule.to_time_of_day + ')';
		}
	}
}).
filter('startEarlyEndLate', function() {
	return function(schedule) {
		var sentences = [];
		if (schedule.custom_start_early_minutes) {
			sentences.push('starts ' + schedule.custom_start_early_minutes + ' minutes early');
		}
		if (schedule.custom_end_late_minutes) {
			sentences.push('ends ' + schedule.custom_end_late_minutes + ' minutes late');
		}
		if (sentences.length > 0) {
			return '(' + sentences.join(', ') + ')';
		}
		return '';
	}
});