var gulp = require('gulp');
var gutil= require('gulp-util');
var sass = require('gulp-sass');
var watch = require('gulp-watch');

js_files = [
  './js/*.coffee',
  './js/**/*.coffee',
  './js/**/**/*.coffee'
]

css_files = './assets/scss/*.scss'

hbs_files =[
  './js/*.hbs',
  './js/**/*.hbs',
  './js/**/**/*.hbs'
]

gulp.task('libs', function(){
  return gulp.src(['./js/lib/*', './js/lib/**'])
    .pipe(gulp.dest('./static/js/lib/'));
});

gulp.task('coffee', function() {
  gulp.src(js_files)
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./static/js/'))
});

gulp.task('sass', function() {
  return gulp.src(css_files)
    .pipe(sass({ errLogToConsole: true }).on('error', gutil.log))
    .pipe(gulp.dest('./static/css/'))
});

// gulp.task('bower', function() {
//   return bower()
//     .pipe(gulp.dest('static/js/lib/'))
// });

gulp.task('hbs', function() {
  return gulp.src(hbs_files)
    .pipe(gulp.dest('./static/js'));
});

gulp.task('watch', function() {
  gulp.watch(css_files, ['sass']);
});


gulp.task('build', ['sass']);
