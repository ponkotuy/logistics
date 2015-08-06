gulp = require 'gulp'
coffee = require 'gulp-coffee'
plumber = require 'gulp-plumber'

gulp.task 'default', ['coffee', 'js', 'watch']

gulp.task 'watch', ->
  gulp.watch ['src/coffee/*.coffee'], ['coffee']
  gulp.watch ['src/js/*.js'], ['js']

gulp.task 'coffee', ->
  gulp.src ['src/coffee/*.coffee']
    .pipe plumber()
    .pipe coffee()
    .pipe gulp.dest('js/')

gulp.task 'js', ->
  gulp.src ['src/js/*.js']
    .pipe gulp.dest('js/')
