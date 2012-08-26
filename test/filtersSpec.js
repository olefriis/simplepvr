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
});