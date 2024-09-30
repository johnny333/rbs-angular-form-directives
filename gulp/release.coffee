_          = require 'lodash'
argv       = require('minimist')(process.argv.slice(2))
bump       = require 'gulp-bump'
common     = require './commons'
debug      = require 'gulp-debug'
gulp       = require 'gulp'
plumber    = require 'gulp-plumber'
rev        = require 'gulp-rev'
revReplace = require 'gulp-rev-replace'

gulpModule =

  ###
    Performs asset revisioning on files.

    Arguments:
      - options: object
        * name: string          - task name
        * src: string|array     - glob(s) for files to process
        * dest: string          - destination directory
  ###
  revise: (options = {}) ->
    _.defaults options, name: 'revise'
    (watch) ->
      gulp.src(options.src)
        .pipe(plumber(errorHandler: common.errorHandler(watch)))
        .pipe(debug title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("revise"))
        .pipe(rev())
        .pipe(gulp.dest(options.dest))
        .pipe(rev.manifest())
        .pipe(debug title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("manifest"))
        .pipe(gulp.dest(options.dest))

  ###
    Replaces names of revisioned assets in files.

    Arguments:
      - options: object
        * name: string          - task name
        * src: string|array     - glob(s) for files to process
        * manifest: string      - manifest file (default: rev-manifest.json)
        * dest: string          - destination directory
  ###
  revReplace: (options = {}) ->
    _.defaults options,
      name: 'revise'
      manifest: 'rev-manifest.json'
    (watch) ->
      manifest = gulp.src options.manifest
      gulp.src(options.src)
        .pipe(plumber(errorHandler: common.errorHandler(watch)))
        .pipe(debug title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("rev-replace"))
        .pipe(revReplace(manifest: manifest))
        .pipe(gulp.dest(options.dest))

  ###
    Copies files from one location to another.

    Arguments:
      - options: object
        * name: string          - task name
        * src: string|array     - glob(s) for files to process
        * dest: string          - destination directory
  ###
  copy: (options = {}) ->
    _.defaults options, name: 'copy'
    (watch) ->
      gulp.src(options.src)
        .pipe(plumber(errorHandler: common.errorHandler(watch)))
        .pipe(debug title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("copy"))
        .pipe(gulp.dest(options.dest))

  ###
    Bumps revision in project files.

    Arguments:
      - options: object
        * name: string          - task name
        * src: string|array     - glob(s) for files to process (default: ['package.json', 'bower.json'])
        * version: string       - version to bump to (default: --version command line argument or next `versionType` version)
        * versionType: string   - version to bump to (default: --version-type command line argument or "patch")
        * dest: string          - destination directory (default: './')
  ###
  bump: (options = {}) ->
    _.defaults options,
      name: 'bump'
      src: [
        'package.json'
        'bower.json'
      ]
      version: argv['version']
      versionType: argv['version-type']
      dest: './'
    (watch) ->
      gulp.src(options.src)
        .pipe(plumber(errorHandler: common.errorHandler(watch)))
        .pipe(debug title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("bump"))
        .pipe(bump { version: options.version, type: options.versionType })
        .pipe(gulp.dest(options.dest))

module.exports = gulpModule
