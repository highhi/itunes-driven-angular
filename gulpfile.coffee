'use strict'

# PLUGINS
gulp 		= require 'gulp'
sync 		= require 'browser-sync'
del 		= require 'del'
handleErrors 	= require './handleErrors'
seque 		= require 'run-sequence'
browserify	= require 'browserify'
source		= require 'vinyl-source-stream'
buffer		= require 'vinyl-buffer'
$ 			= require('gulp-load-plugins')()

# html minify
gulp.task 'html', ->
	gulp.src 'dev/**/*.html'
	.pipe $.plumber()
	.pipe $.minifyHtml
		conditionals : true
		quotes : true
	.pipe gulp.dest 'public'

# sass compile
gulp.task 'sass', ->
	$.rubySass 'dev/scss/',
		style : 'compressed'
		compass : true
		sourcemap: true
	.pipe $.sourcemaps.write './',
		sourceRoot : '/dev/scss/'
	.pipe gulp.dest 'public/css'

# js minify
gulp.task 'build', ->
	browserify
		entries : ['dev/js/main.js']
		transform: ['debowerify']
		debug: true
	.bundle()
	.on('error', handleErrors)
	.pipe source 'main.js'
	.pipe buffer()
	# .pipe $.jshint()
	# .pipe $.jshint.reporter 'jshint-stylish'
	.pipe $.sourcemaps.init loadMaps: true
	.pipe $.uglify()
	.pipe $.sourcemaps.write './'
	.pipe gulp.dest 'public/js'

# 画像最適化
gulp.task 'images', ->
	gulp.src 'dev/img/*'
	.pipe $.changed('public/img')
	.pipe $.imagemin
		optimizationLevel : 7
		progressive : true
		interlaced : true
	.pipe gulp.dest('public/img')

# public 初期化
gulp.task 'clean', del.bind(null, ['public'])

# サーバ起動
gulp.task 'sync', ->
	sync.init null,
		server :
			baseDir : 'public'

# ブラウザオートリロード
gulp.task 'reload', ->
	sync.reload()
	
# WATCH
gulp.task 'watch', ->
	gulp.watch 'dev/**/*.html', ['html']
	gulp.watch 'dev/scss/**/*.scss', ['sass']
	gulp.watch 'dev/js/**/*.js', ['build']
	gulp.watch ['dev/img/*', '!dev/img/sprite/*'], ['images']
	gulp.watch ['public/**', '!public/**/*.map', '!public/img/*'], ['reload']

gulp.task 'init', ->
	seque 'clean', 'build', 'sass', ['html', 'images']

gulp.task 'default', ['sync','watch']