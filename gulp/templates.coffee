_               = require 'lodash'
cached          = require 'gulp-cached'
common          = require './commons'
data            = require 'gulp-data'
debug           = require 'gulp-debug'
filter          = require 'gulp-filter'
gif             = require 'gulp-if'
gulp            = require 'gulp'
gutil           = require 'gulp-util'
htmlhint        = require 'gulp-htmlhint'
htmlmin         = require 'gulp-htmlmin'
jade            = require 'gulp-jade'
jadeHelpers     = require './jade-helpers'
lazypipe        = require 'lazypipe'
match           = require 'gulp-match'
minimatch       = require 'minimatch'
plumber         = require 'gulp-plumber'
remember        = require 'gulp-remember'
rename          = require 'gulp-rename'
sourcemaps      = require 'gulp-sourcemaps'
template        = require 'gulp-template'
templateCache   = require 'gulp-angular-templatecache'
uglify          = require 'gulp-uglify'

jadeEngine      = require 'jade'
jadeEngine.filters.svg = _.identity

# Jade templates glob
IS_JADE          = '**/*.jade'

# HTML templates glob
IS_HTML          = '**/*.html'

isJadeFile = (file) -> match(file, IS_JADE)

isHtmlFile = (file) -> match(file, IS_HTML)

###
  Arguments:
    - options: object
      * name: string        - task name
      * pkg: object         - `package.json` object
      * src: string|array   - glob(s) for files to process
      * dest: string        - destination
      * sourcemaps: boolean - write sourcemaps
      * minify: boolean     - minify output
      * module: object      - create angular module from templates (instead of creating templates files)
        - name: string      - module name
        - dest: string      - module file
    - watch: boolean        - is this a `gulp.watch` session
###
gulpModule = (options) ->

  task = (watch = false) ->

    # Jade plugin options
    JADE_OPTS =
      pretty: true
      jade: jadeEngine

    minifyHtmlChannel = lazypipe()
      .pipe(debug, title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("minify HTML"))
      .pipe(htmlmin, collapseWhitespace: true)

    htmlChannel = lazypipe()
      .pipe(debug, title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("hint HTML"))
      .pipe(htmlhint, 'htmlhint.json')
      # FIXME: put lint reports to a file
      .pipe(htmlhint.reporter, "htmlhint-stylish")
      .pipe(htmlhint.failReporter, suppress: true)
      .pipe(-> gif(options.minify, minifyHtmlChannel()))

    jadeChannel = lazypipe()
      .pipe(debug, title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("compile Jade"))
      .pipe(jade, JADE_OPTS)

    minifyModuleChannel = lazypipe()
      .pipe(uglify)
      .pipe(rename, extname: '.min.js')
      .pipe(debug, title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("minify HTML module"))
      .pipe(gulp.dest, options.dest)

    cachedChannel = lazypipe()
      .pipe(templateCache, options.module?.dest, standalone: true, module: options.module?.name)
      .pipe(debug, title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("create HTML module"))
      .pipe(gulp.dest, options.dest)
      .pipe(-> gif(options.sourcemaps, sourcemaps.init debug: true, loadMaps: true))
      .pipe(-> gif(options.minify, minifyModuleChannel()))
      .pipe(-> gif(options.sourcemaps, sourcemaps.write '.'))

    gulp.src(options.src)
      .pipe(plumber(errorHandler: common.errorHandler(watch)))
      .pipe(cached options.name)
      .pipe(data -> package: options.pkg, helpers: jadeHelpers, _: _)
      .pipe(template())
      .pipe(gif(isJadeFile, jadeChannel()))
      .pipe(htmlChannel())
      .pipe(remember options.name)
      .pipe(gif(options.module?, cachedChannel()))
      .pipe(gulp.dest options.dest)

  watch = (tasks) ->
    watched = _.flatten [options.src]
    if options.jadeBasedir?
      watched.push "#{options.jadeBasedir}/**/*.jade"
    watcher = gulp.watch watched, tasks
    watcher.on 'change', (event) ->
      # FIXME: use jade inheritance instead
      if minimatch event.path, IS_JADE
        if cached.caches[options.name]?
          for key, value of cached.caches[options.name]
            delete cached.caches[options.name][key]
      onDeleted = (path) ->
        gutil.log common.colors.task("[#{options.name}]"), common.colors.action("invalidate"), common.colors.file(path)
        if cached.caches[options.name]?
            delete cached.caches[options.name][path]
        if minimatch path, IS_JADE
          # Jade files are remembered after compilation to HTML - change extension
          path = gutil.replaceExtension path, '.html'
        gutil.log common.colors.task("[#{options.name}]"), common.colors.action("forget"), common.colors.file(path)
        remember.forget options.name, path
      if event.type is 'deleted'
        onDeleted(event.path)

  task: task
  watch: watch

module.exports = gulpModule
