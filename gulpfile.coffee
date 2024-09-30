pkg              = require './package.json'
_                = require 'lodash'
browser          = require('browser-sync').create()
connect          = require 'gulp-connect'
del              = require 'del'
gulp             = require 'gulp'
inject           = require 'gulp-inject'
karma            = require 'karma'
sequence         = require 'gulp-sequence'

gulpTemplates    = require './gulp/templates'
gulpScripts      = require './gulp/scripts'
gulpStylesheets  = require './gulp/stylesheets'
gulpLibs         = require './gulp/libs'
gulpRelease      = require './gulp/release'
gulpGit          = require './gulp/git'
gulpProtractor   = require './gulp/protractor'

BOWER_DIR        = 'bower_components'
NPM_DIR          = 'node_modules'
SRC_DIR          = 'src'
SRC_MAIN_DIR     = "#{SRC_DIR}/main"
SRC_SAMPLES_DIR  = "#{SRC_DIR}/samples"
SRC_TEST_DIR     = "#{SRC_DIR}/test"
SRC_UNIT_DIR     = "#{SRC_TEST_DIR}/unit"
SRC_E2E_DIR      = "#{SRC_TEST_DIR}/e2e"
TARGET_DIR       = 'target'
TARGET_MAIN_DIR  = "#{TARGET_DIR}/main"
TARGET_TEST_DIR  = "#{TARGET_DIR}/test"
TARGET_UNIT_DIR  = "#{TARGET_TEST_DIR}/unit"
TARGET_E2E_DIR   = "#{TARGET_TEST_DIR}/e2e"
DIST_DIR         = 'dist'

BUMPED           = [
  'package.json'
  'bower.json'
]

CONNECT_CONFIG   =
  root: TARGET_MAIN_DIR
  port: 3000

BROWSER_CONFIG  =
  files: false
  logConnections: true
  logFileChanges: true
  logLevel: 'debug'
  logPrefix: "#{pkg.name}"
  browser: ["google-chrome"]
  reloadDelay: 1000
  reloadDebounce: 1000
  port: 3000

JS_LIBS          = [
  "#{BOWER_DIR}/lodash/dist/lodash.js"
  "#{BOWER_DIR}/string/dist/string.js"
  "#{BOWER_DIR}/angular/angular.js"
  "#{BOWER_DIR}/angular-messages/angular-messages.js"
  "#{BOWER_DIR}/angular-i18n/angular-locale_pl-pl.js"
]

JS_TEST_LIBS     = [
  "#{BOWER_DIR}/angular-mocks/angular-mocks.js"
  "#{BOWER_DIR}/jasmine-jquery/lib/jasmine-jquery.js"
  "#{BOWER_DIR}/jasmine-promise-matchers/dist/jasmine-promise-matchers.js"
  "#{BOWER_DIR}/jasmine-object-matchers/dist/jasmine-object-matchers.js"
]

CSS_LIBS         = [
  "#{BOWER_DIR}/bootstrap/dist/css/bootstrap.css"
]

jsonInject = (filepath, file, i, length) ->
  '"' + filepath + '"' + if i + 1 < length then ',' else ''

samplesTemplates = gulpTemplates
  name: 'samples-templates'
  pkg: pkg
  src: [
    "#{SRC_SAMPLES_DIR}/jade/**/*.jade"
    "#{SRC_SAMPLES_DIR}/html/**/*.html"
  ]
  jadeBasedir: "#{SRC_SAMPLES_DIR}/jade"
  dest: TARGET_MAIN_DIR
  sourcemaps: true

samplesBootScript = gulpScripts
  name: 'samples-boot-script'
  pkg: pkg
  src: [
    "#{SRC_SAMPLES_DIR}/coffee/boot.{coffee,litcoffee}"
    "#{SRC_SAMPLES_DIR}/js/boot.js"
  ]
  dest: "#{TARGET_MAIN_DIR}/js"
  concat: "#{pkg.name}-samples-boot.js"
  sourcemaps: true

samplesScripts = gulpScripts
  name: 'samples-scripts'
  pkg: pkg
  src: [
    "#{SRC_SAMPLES_DIR}/coffee/**/*.{coffee,litcoffee}"
    "#{SRC_SAMPLES_DIR}/js/**/*.js"
    "!#{SRC_SAMPLES_DIR}/coffee/boot.{coffee,litcoffee}"
    "!#{SRC_SAMPLES_DIR}/js/boot.js"
  ]
  dest: "#{TARGET_MAIN_DIR}/js"
  concat: "#{pkg.name}-samples.js"
  sourcemaps: true

moduleScripts = gulpScripts
  name: 'module-scripts'
  pkg: pkg
  src: [
    "#{SRC_MAIN_DIR}/coffee/**/*.{coffee,litcoffee}"
    "#{SRC_MAIN_DIR}/js/**/*.js"
  ]
  dest: "#{TARGET_MAIN_DIR}/js"
  concat: "#{pkg.name}.js"
  sourcemaps: true

samplesStylesheets = gulpStylesheets
  name: 'samples-stylesheets'
  pkg: pkg
  src: [
    "#{SRC_SAMPLES_DIR}/less/style.less"
    "#{SRC_SAMPLES_DIR}/sass/style.s{a,c}ss"
    "#{SRC_SAMPLES_DIR}/css/**/*.css"
  ]
  dest: "#{TARGET_MAIN_DIR}/css"
  concat: "#{pkg.name}-samples-style.css"
  lessBasedir: "#{SRC_SAMPLES_DIR}/less"
  sassBasedir: "#{SRC_SAMPLES_DIR}/sass"
  sourcemaps: true

jsLibs = gulpLibs
  name: 'js-libs'
  pkg: pkg
  src: JS_LIBS
  dest: "#{TARGET_MAIN_DIR}/js"
  concat: "#{pkg.name}-lib.js"

cssLibs = gulpLibs
  name: 'css-libs'
  pkg: pkg
  src: CSS_LIBS
  dest: "#{TARGET_MAIN_DIR}/css"
  concat: "#{pkg.name}-samples-lib.css"

unitTests = gulpScripts
  name: 'test-unit'
  pkg: pkg
  src: [
    "#{SRC_UNIT_DIR}/coffee/**/*.{coffee,litcoffee}"
    "#{SRC_UNIT_DIR}/js/**/*.js"
  ]
  dest: "#{TARGET_UNIT_DIR}/js"

e2eTests = gulpScripts
  name: 'test-e2e'
  pkg: pkg
  src: [
    "#{SRC_E2E_DIR}/coffee/**/*.{coffee,litcoffee}"
    "#{SRC_E2E_DIR}/js/**/*.js"
  ]
  dest: "#{TARGET_E2E_DIR}/js"

copyDist = gulpRelease.copy
  src: "#{TARGET_MAIN_DIR}/**"
  dest: DIST_DIR

bump = gulpRelease.bump
  src: BUMPED
  dest: './'

gitAdd = gulpGit.add
  src: "**"

gitCommit = gulpGit.commit
  src: "**"

gitTag = gulpGit.tag
  src: "package.json"

gitPush = gulpGit.push
  src: "package.json"

samplesIndexInject = ->
  headScripts = gulp.src [
    "#{TARGET_MAIN_DIR}/js/#{pkg.name}-lib.js"
    "#{TARGET_MAIN_DIR}/js/#{pkg.name}.js"
    "#{TARGET_MAIN_DIR}/js/#{pkg.name}-samples.js"
  ]
  bodyScript = gulp.src "#{TARGET_MAIN_DIR}/js/#{pkg.name}-samples-boot.js"
  headStyles = gulp.src [
    "#{TARGET_MAIN_DIR}/css/#{pkg.name}-samples-lib.css"
    "#{TARGET_MAIN_DIR}/css/#{pkg.name}-samples-style.css"
  ]
  gulp.src("#{TARGET_MAIN_DIR}/index.html")
    .pipe(inject(headStyles, relative: true))
    .pipe(inject(headScripts, relative: true))
    .pipe(inject(bodyScript, name: 'boot', relative: true))
    .pipe(gulp.dest(TARGET_MAIN_DIR))

karmaConfInject = ->
  karmaScripts = _.flatten [
    "#{TARGET_MAIN_DIR}/js/#{pkg.name}-lib.js"
    JS_TEST_LIBS
    "#{TARGET_MAIN_DIR}/js/#{pkg.name}.js"
    "#{TARGET_UNIT_DIR}/js/**/*.js"
  ]
  testScripts = gulp.src karmaScripts
  gulp.src('karma.conf.js')
    .pipe(inject(testScripts, relative: true, starttag: 'files: [', endtag: ']', transform: jsonInject))
    .pipe(gulp.dest('./'));

protractorConfInject = ->
  testScripts = gulp.src "#{TARGET_E2E_DIR}/js/**/*.js"
  gulp.src('protractor.conf.js')
    .pipe(inject(testScripts, relative: true, starttag: 'specs: [', endtag: ']', transform: jsonInject))
    .pipe(gulp.dest('./'));

###
  Clean project
###
gulp.task 'clean', ->
  del [
    "#{TARGET_DIR}/**"
    "#{DIST_DIR}/**"
  ]

###
  Run `browser-sync` with proxy configuration (uses nginx)
###
gulp.task 'browser-proxy', (cb) ->
  browser.init _.defaults({
    proxy:
      target: "http://#{pkg.name}.dev",
      ws: true
  }, BROWSER_CONFIG), cb

###
  Run `browser-sync` with standalone configuration
###
gulp.task 'browser', (cb) ->
  browser.init _.defaults({
    server:
      baseDir: TARGET_MAIN_DIR
      index: "index.html"
  }, BROWSER_CONFIG), cb

###
  Reload browser
###
gulp.task 'browser-reload', (cb) ->
  browser.reload()
  cb()

###
  Exit browser
###
gulp.task 'browser-exit', (cb) ->
  browser.exit()
  cb()

###
  Run unit tests
###
gulp.task 'karma-run', (done) ->
  new karma.Server({configFile: "#{__dirname}/karma.conf.js", singleRun: true}, done).start()

###
  Run and watch unit tests
###
gulp.task 'karma-watch', (done) ->
  new karma.Server(configFile: "#{__dirname}/karma.conf.js", singleRun: false).start()
  done()

###
  Install protractor dependencies
###
gulp.task 'protractor-install', (done) ->
  gulpProtractor.installTask(done)

###
  Run protractor (E2E tests)
###
gulp.task 'protractor-run', (done) ->
  connect.server CONNECT_CONFIG
  cb = (err) ->
    connect.serverClose()
    done(err)
  gulpProtractor.runTask([])(cb)

###
  Inject dependencies into `index.html`
###
gulp.task 'inject-samples-index.html', samplesIndexInject

###
  Inject dependencies into `karma.conf`
###
gulp.task 'inject-karma.conf', karmaConfInject

###
  Inject dependencies into `protractor.conf`
###
gulp.task 'inject-protractor.conf', protractorConfInject

###
  Compile samples templates
###
gulp.task 'samples-templates', -> samplesTemplates.task()
gulp.task 'refresh-samples-templates', -> samplesTemplates.task(true)

###
  Compile module templates
###
gulp.task 'templates', ['samples-templates']
gulp.task 'refresh-templates', ['refresh-samples-templates']

###
  Compile samples scripts
###
gulp.task 'samples-scripts', -> samplesScripts.task()
gulp.task 'refresh-samples-scripts', -> samplesScripts.task(true)

###
  Compile samples Angular.js boot script
###
gulp.task 'samples-boot-script', -> samplesBootScript.task()
gulp.task 'refresh-samples-boot-script', -> samplesBootScript.task(true)

###
  Compile `#{pkg.name}` Angular.js module code in `js/#{pkg.name}.js`
###
gulp.task 'module-scripts', -> moduleScripts.task()
gulp.task 'refresh-module-scripts', -> moduleScripts.task(true)

###
  Compile module code
###
gulp.task 'scripts', ['samples-boot-script', 'samples-scripts', 'module-scripts']
gulp.task 'refresh-scripts', ['refresh-samples-boot-script', 'refresh-samples-scripts', 'refresh-module-scripts']

###
  Compile samples stylesheet in `css/#{pkg.name}-samples-style.css`
###
gulp.task 'samples-stylesheets', -> samplesStylesheets.task()
gulp.task 'refresh-samples-stylesheets', -> samplesStylesheets.task(true).pipe(browser.stream match: '**/*.css')

###
  Compile module stylesheets
###
gulp.task 'stylesheets', ['samples-stylesheets']
gulp.task 'refresh-stylesheets', ['refresh-samples-stylesheets']

###
  Compile module JavaScript libraries `js/#{pkg.name}-lib.js`
###
gulp.task 'js-libs', -> jsLibs.task()
gulp.task 'refresh-js-libs', -> jsLibs.task(true)

###
  Compile samples CSS libraries `css/#{pkg.name}-samples-lib.css`
###
gulp.task 'css-libs', -> cssLibs.task()
gulp.task 'refresh-css-libs', -> cssLibs.task(true).pipe(browser.stream match: '**/*.css')

###
  Compile module libraries
###
gulp.task 'libs', ['js-libs', 'css-libs']
gulp.task 'refresh-libs', ['refresh-js-libs', 'refresh-css-libs']

###
  Compile module unit tests in `unit/js`
###
gulp.task 'test-unit', -> unitTests.task()
gulp.task 'refresh-test-unit', -> unitTests.task(true)

###
  Compile module E2E tests in `e2e/js`
###
gulp.task 'test-e2e', -> e2eTests.task()
gulp.task 'refresh-test-e2e', -> e2eTests.task(true)

###
  Compile module code
###
gulp.task 'compile', ['templates', 'scripts', 'stylesheets', 'libs']
gulp.task 'refresh-compile', ['refresh-templates', 'refresh-scripts', 'refresh-stylesheets', 'refresh-libs']

###
  Compile test code
###
gulp.task 'test-compile', ['test-unit', 'test-e2e']
gulp.task 'refresh-test-compile', ['refresh-test-unit', 'refresh-test-e2e']

###
  Inject compiled files
###
gulp.task 'inject', ['inject-samples-index.html']

###
  Inject test configuration files
###
gulp.task 'test-inject', ['inject-karma.conf', 'inject-protractor.conf']

gulp.task 'build', sequence(['compile', 'test-compile'], ['inject', 'test-inject'])

gulp.task 'e2e-test', sequence('protractor-install', 'protractor-run')

gulp.task 'unit-test', ['karma-run']

gulp.task 'copy-dist', -> copyDist()

gulp.task 'create-dist', ['copy-dist']

gulp.task 'bump', -> bump()

gulp.task 'git-add', -> gitAdd()

gulp.task 'git-commit', -> gitCommit()

gulp.task 'git-tag', -> gitTag()

gulp.task 'git-push', -> gitPush()

gulp.task 'git', sequence 'git-add', 'git-commit', 'git-tag', 'git-push'

gulp.task 'dist', sequence 'clean', 'build', 'unit-test', 'e2e-test', 'create-dist'

gulp.task 'release', sequence 'bump', 'dist', 'git'

gulp.task 'default', sequence('clean', 'build', ['karma-watch', 'browser', 'watch'])

# FIXME: browser reloaded even if only styles are changed (no relaod required)
gulp.task 'refresh', (done) -> sequence(['refresh-compile', 'refresh-test-compile'], ['inject', 'test-inject'], 'browser-reload')(done)

gulp.task 'watch', () ->
  samplesTemplates.watch ['refresh']
  samplesBootScript.watch ['refresh']
  samplesScripts.watch ['refresh']
  moduleScripts.watch ['refresh']
  samplesStylesheets.watch ['refresh']
  cssLibs.watch ['refresh']
  jsLibs.watch ['refresh']
  unitTests.watch ['refresh']
