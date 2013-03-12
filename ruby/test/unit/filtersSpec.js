'use strict';

describe('filters', function() {
	beforeEach(module('simplePvr'));
	
	describe('chunk', function() {
		it('should let non-Array input pass through', inject(function(chunkFilter) {
			var input = 'this is not an array';
			expect(chunkFilter(input)).toBe(input);
		}));
		
		it('should let empty arrays pass through', inject(function(chunkFilter) {
			expect(chunkFilter([], 3)).toEqual([]);
		}));
		
		it('should chunk up arrays and give them hashKeys corresponding to the chunk numbers', inject(function(chunkFilter) {
			var input = [1, 2, 3, 4, 5, 6, 7];
			var firstChunk = [1, 2, 3];
			var secondChunk = [4, 5, 6];
			var thirdChunk = [7];
			
			firstChunk.$$hashKey = 0;
			secondChunk.$$hashKey = 1;
			thirdChunk.$$hashKey = 2;
			
			expect(chunkFilter(input, 3)).toEqual([firstChunk, secondChunk, thirdChunk]);
		}));
		
		it('should create equal outputs given equal inputs', inject(function(chunkFilter) {
			var output1 = chunkFilter([1, 2, 3, 4], 3);
			var output2 = chunkFilter([1, 2, 3, 4], 3);
			expect(angular.equals(output1, output2)).toBeTruthy();
		}));
		
		it('should create non-equal outputs given non-equal inputs', inject(function(chunkFilter) {
			var output1 = chunkFilter([1, 2, 3, 4], 3);
			var output2 = chunkFilter([4, 3, 2, 1], 3);
			expect(angular.equals(output1, output2)).toBeFalsy();
		}));
	});
	
	describe('weekdayFilter', function() {
		it('should be blank when there is no weekday filtering', inject(function(filteredWeekdaysFilter) {
			var scheduleWithNoWeekdayFiltering = { filter_by_weekday: false };
			expect(filteredWeekdaysFilter(scheduleWithNoWeekdayFiltering)).toEqual('');
		}));
		
		it('should name a single weekday if only one is selected', inject(function(filteredWeekdaysFilter) {
			var scheduleWithOneWeekdayFiltering = {
				filter_by_weekday: true,
				monday: false,
				tuesday: false,
				wednesday: true,
				thursday: false,
				friday: false,
				saturday: false,
				sunday: false
			};
			expect(filteredWeekdaysFilter(scheduleWithOneWeekdayFiltering)).toEqual('(Wednesdays)');
		}));
		
		it('should name two weekdays if exactly two are selected', inject(function(filteredWeekdaysFilter) {
			var scheduleWithTwoWeekdayFilterings = {
				filter_by_weekday: true,
				monday: true,
				tuesday: false,
				wednesday: true,
				thursday: false,
				friday: false,
				saturday: false,
				sunday: false
			};
			expect(filteredWeekdaysFilter(scheduleWithTwoWeekdayFilterings)).toEqual('(Mondays and Wednesdays)');
		}));
		
		it('should list all weekdays for three and more allowed weekdays', inject(function(filteredWeekdaysFilter) {
			var scheduleWithSeveralWeekdayFilterings = {
				filter_by_weekday: true,
				monday: true,
				tuesday: false,
				wednesday: true,
				thursday: false,
				friday: true,
				saturday: false,
				sunday: false
			};
			expect(filteredWeekdaysFilter(scheduleWithSeveralWeekdayFilterings)).toEqual('(Mondays, Wednesdays, and Fridays)');
			scheduleWithSeveralWeekdayFilterings.saturday = true;
			expect(filteredWeekdaysFilter(scheduleWithSeveralWeekdayFilterings)).toEqual('(Mondays, Wednesdays, Fridays, and Saturdays)');
			scheduleWithSeveralWeekdayFilterings.tuesday = true;
			scheduleWithSeveralWeekdayFilterings.thursday = true;
			scheduleWithSeveralWeekdayFilterings.saturday = true;
			scheduleWithSeveralWeekdayFilterings.sunday = true;
			expect(filteredWeekdaysFilter(scheduleWithSeveralWeekdayFilterings)).toEqual('(Mondays, Tuesdays, Wednesdays, Thursdays, Fridays, Saturdays, and Sundays)')
		}));
	});
});