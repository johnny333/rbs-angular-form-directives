_                = require 'lodash'
angularFilesort  = require 'gulp-angular-filesort'
cached           = require 'gulp-cached'
coffee           = require 'gulp-coffee'
coffeelint       = require 'gulp-coffeelint'
common           = require './commons'
concat           = require 'gulp-concat'
data             = require 'gulp-data'
debug            = require 'gulp-debug'
filter           = require 'gulp-filter'
footer           = require 'gulp-footer'
gif              = require 'gulp-if'
gulp             = require 'gulp'
gutil            = require 'gulp-util'
header           = require 'gulp-header'
indent           = require 'gulp-indent'
jshint           = require 'gulp-jshint'
lazypipe         = require 'lazypipe'
match            = require 'gulp-match'
minimatch        = require 'minimatch'
plumber          = require 'gulp-plumber'
remember         = require 'gulp-remember'
rename           = require 'gulp-rename'
sourcemaps       = require 'gulp-sourcemaps'
template         = require 'gulp-template'
uglify           = require 'gulp-uglify'

# Coffee script glob
IS_COFFEE_SCRIPT = '**/*.{coffee,litcoffee}'
# JavaScript script glob
IS_JAVA_SCRIPT   = '**/*.js'

isCoffeeScriptFile = (file) -> match(file, IS_COFFEE_SCRIPT)

isJavaScriptFile = (file) -> match(file, IS_JAVA_SCRIPT)

###
  Arguments:
    - options: object
      * name: string        - task name
      * pkg: object         - `package.json` object
      * src: string|array   - glob(s) for files to process
      * dest: string        - destination
      * concat: string      - concatenate to this file
      * sourcemaps: boolean - write sourcemaps
      * minify: boolean     - minify output
    - watch: boolean        - is this a `gulp.watch` session
###
gulpModule = (options) ->

  task = (watch = false) ->

    javaScriptChannel = lazypipe()
      .pipe(debug, title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("process JavaScript"))
      .pipe(indent)
      # no conflict
      .pipe(header, '(function() {\n')
      .pipe(footer, '\n}).call(this);')
      .pipe(debug, title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("lint JavaScript"))
      .pipe(jshint)
      .pipe(jshint.reporter, 'jshint-stylish')
      # FIXME: put lint reports to a file
      .pipe(jshint.reporter, 'fail')

    coffeeScriptChannel = lazypipe()
      .pipe(debug, title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("lint Coffee"))
      .pipe(coffeelint, 'coffeelint.json')
      .pipe(coffeelint.reporter, 'coffeelint-stylish')
      # FIXME: put lint reports to a file
      .pipe(coffeelint.reporter, 'fail')
      .pipe(debug, title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("compile Coffee"))
      .pipe(coffee)

    doMinifyChannel = lazypipe()
      .pipe(uglify)
      .pipe(rename, extname: '.min.js')
      .pipe(debug, title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("minify JavaScript"))

    minifyChannel = lazypipe()
      .pipe(-> gif(common.predicates.isNotSourcemapFile, doMinifyChannel()))
      .pipe(-> gif(options.sourcemaps, sourcemaps.write '.'))
      .pipe(gulp.dest, options.dest)

    gulp.src(options.src)
      .pipe(plumber(errorHandler: common.errorHandler(watch)))
      .pipe(cached options.name)
      .pipe(data -> package: options.pkg)
      .pipe(template())
      .pipe(gif(options.sourcemaps, sourcemaps.init debug: true, loadMaps: true))
      .pipe(gif(isJavaScriptFile, javaScriptChannel()))
      .pipe(gif(isCoffeeScriptFile, coffeeScriptChannel()))
      .pipe(remember options.name)
      .pipe(angularFilesort())
      .pipe(gif(options.concat?, concat options.concat or "#{options.pkg.name}-#{options.name}.js"))
      .pipe(gif(options.sourcemaps, sourcemaps.write '.'))
      .pipe(gulp.dest options.dest)
      .pipe(gif(options.minify, minifyChannel()))

  watch = (tasks) ->
    watcher = gulp.watch options.src, tasks
    watcher.on 'change', (event) ->
      onDeleted = (path) ->
        gutil.log common.colors.task("[#{options.name}]"), common.colors.action("invalidate"), common.colors.file(path)
        if cached.caches[options.name]?
          delete cached.caches[options.name][path]
        if minimatch path, IS_COFFEE_SCRIPT
          # Coffee files are remembered after compilation to JavaScript - change extension
          path = gutil.replaceExtension path, '.js'
        gutil.log common.colors.task("[#{options.name}]"), common.colors.action("forget"), common.colors.file(path)
        remember.forget options.name, path
      if event.type is 'deleted'
        onDeleted(event.path)

  task: task
  watch: watch

module.exports = gulpModule
