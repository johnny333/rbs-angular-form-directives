_                = require 'lodash'
cached           = require 'gulp-cached'
common           = require './commons'
concat           = require 'gulp-concat'
data             = require 'gulp-data'
debug            = require 'gulp-debug'
gif              = require 'gulp-if'
gulp             = require 'gulp'
gutil            = require 'gulp-util'
lazypipe         = require 'lazypipe'
plumber          = require 'gulp-plumber'
remember         = require 'gulp-remember'
sourcemaps       = require 'gulp-sourcemaps'

###
  Arguments:
    - options: object
      * name: string        - task name
      * pkg: object         - `package.json` object
      * src: string|array   - glob(s) for files to process
      * dest: string        - destination
      * concat: string      - concatenate to this file
      * sourcemaps: boolean - write sourcemaps
    - watch: boolean        - is this a `gulp.watch` session
###
gulpModule = (options) ->

  task = (watch = false) ->

    gulp.src(options.src)
      .pipe(plumber(errorHandler: common.errorHandler(watch)))
      .pipe(cached options.name)
      .pipe(data -> package: options.pkg)
      .pipe(gif(options.sourcemaps, sourcemaps.init debug: true, loadMaps: true))
      .pipe(debug title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("process lib"))
      .pipe(remember options.name)
      .pipe(gif(options.concat?, concat options.concat or "#{options.pkg.name}-libs.js"))
      .pipe(gif(options.sourcemaps, sourcemaps.write '.'))
      .pipe(gulp.dest options.dest)

  watch = (tasks) ->
    watcher = gulp.watch options.src, tasks
    watcher.on 'change', (event) ->
      onDeleted = (path) ->
        gutil.log common.colors.task("[#{options.name}]"), common.colors.action("invalidate"), common.colors.file(path)
        if cached.caches[options.name]?
          delete cached.caches[options.name][path]
        gutil.log common.colors.task("[#{options.name}]"), common.colors.action("forget"), common.colors.file(path)
        remember.forget options.name, path
      if event.type is 'deleted'
        onDeleted(event.path)

  task: task
  watch: watch

module.exports = gulpModule
