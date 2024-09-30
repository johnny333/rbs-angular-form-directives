_               = require 'lodash'
autoprefixer    = require 'gulp-autoprefixer'
cached          = require 'gulp-cached'
common          = require './commons'
concat          = require 'gulp-concat'
csscomb         = require 'gulp-csscomb'
csslint         = require 'gulp-csslint'
data            = require 'gulp-data'
debug           = require 'gulp-debug'
filter          = require 'gulp-filter'
gif             = require 'gulp-if'
gulp            = require 'gulp'
gutil           = require 'gulp-util'
lazypipe        = require 'lazypipe'
less            = require 'gulp-less'
match           = require 'gulp-match'
minifyCss       = require 'gulp-minify-css'
minimatch       = require 'minimatch'
plumber         = require 'gulp-plumber'
remember        = require 'gulp-remember'
rename          = require 'gulp-rename'
sass            = require 'gulp-sass'
sourcemaps      = require 'gulp-sourcemaps'
template        = require 'gulp-template'

# SASS stylesheet glob
IS_SASS         = '**/*.s{a,c}ss'
# LESS stylesheet glob
IS_LESS         = '**/*.less'
# CSS stylesheet glob
IS_CSS          = '**/*.css'

isSassFile = (file) -> match(file, IS_SASS)

isLessFile = (file) -> match(file, IS_LESS)

isCssFile = (file) -> match(file, IS_CSS)

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
      * lessBasedir: string - basedir for LESS stylesheets
      * sassBasedir: string - basedir for SASS stylesheets
    - watch: boolean        - is this a `gulp.watch` session
###
gulpModule = (options) ->

  task = (watch = false) ->

    cssChannel = lazypipe()
      .pipe(debug, title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("prefix CSS"))
      .pipe(autoprefixer)
      .pipe(csscomb)
      .pipe(debug, title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("lint CSS"))
      .pipe(csslint)
      # FIXME: put lint reports to a file
      .pipe(csslint.reporter)

    lessChannel = lazypipe()
      # FIXME: handle changes in LESS includes
      .pipe(debug, title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("compile LESS"))
      .pipe(less, paths: [options.lessBasedir])

    sassChannel = lazypipe()
      # FIXME: handle changes in LESS includes
      .pipe(debug, title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("compile SASS"))
      .pipe(sass, includePaths: [options.sassBasedir])

    doMinifyChannel = lazypipe()
      .pipe(minifyCss, keepSpecialComments: '*', sourceMap: true, advanced: false)
      .pipe(rename, extname: '.min.css')
      .pipe(debug, title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("minify CSS"))

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
      .pipe(gif(isLessFile, lessChannel()))
      .pipe(gif(isSassFile, sassChannel()))
      .pipe(cssChannel())
      .pipe(remember options.name)
      .pipe(gif(options.concat?, concat options.concat or "#{options.pkg.name}-#{options.name}.css"))
      .pipe(gif(options.sourcemaps, sourcemaps.write '.'))
      .pipe(gulp.dest options.dest)
      .pipe(gif(options.minify, minifyChannel()))
      .pipe(filter IS_CSS) # pomiń sourcemapy

  watch = (tasks) ->
    watched = _.flatten [options.src]
    if options.lessBasedir?
      watched.push "#{options.lessBasedir}/**/*.less"
    if options.sassBasedir?
      watched.push "#{options.sassBasedir}/**/*.s{a,c}ss"
    watcher = gulp.watch watched, tasks
    watcher.on 'change', (event) ->
      # FIXME: use less/sass inheritance
      if not minimatch event.path, IS_CSS
        if cached.caches[options.name]?
          for key, value of cached.caches[options.name]
            delete cached.caches[options.name][key]
      onDeleted = (path) ->
        gutil.log common.colors.task("[#{options.name}]"), common.colors.action("invalidate"), common.colors.file(path)
        if cached.caches[options.name]?
          delete cached.caches[options.name][path]
        if not minimatch path, IS_CSS
          # LESS and SASS files are remembered after compilation to CSS - change extension
          path = gutil.replaceExtension path, '.css'
        gutil.log common.colors.task("[#{options.name}]"), common.colors.action("forget"), common.colors.file(path)
        remember.forget options.name, path
      if event.type is 'deleted'
        onDeleted(event.path)

  task: task
  watch: watch

module.exports = gulpModule
