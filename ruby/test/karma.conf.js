basePath = '../';

files = [
  JASMINE,
  JASMINE_ADAPTER,
  'http://ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js',
  'public/js/angular/angular.min.js',
  'public/js/angular/angular-*.js',
  'test/lib/angular/angular-mocks.js',
  'public/js/**/*.js',
  'test/unit/**/*.js'
];

autoWatch = true;

browsers = ['Chrome'];

reporters = ['dots']
