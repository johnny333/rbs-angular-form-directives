_          = require 'lodash'
argv       = require('minimist')(process.argv.slice(2))
common     = require './commons'
debug      = require 'gulp-debug'
filter     = require 'gulp-filter'
git        = require 'gulp-git'
gulp       = require 'gulp'
plumber    = require 'gulp-plumber'
tagVersion = require 'gulp-tag-version'
gitIgnore  = require 'gulp-exclude-gitignore'

IS_FILE    = (file) -> file.stat.isFile()

gulpModule =

  ###
    Adds files to Git.

    Arguments:
      - options: object
        * name: string          - task name
        * src: string|array     - glob(s) for files to process (.gitignore files and directories will be ommited)
        * options: object       - git-add options
  ###
  add: (options = {}) ->
    _.defaults options,
      name: 'git-add'
      options:
        args: '--all'
    (watch) ->
      gulp.src(options.src)
        .pipe(plumber(errorHandler: common.errorHandler(watch)))
        .pipe(gitIgnore())
        .pipe(filter(IS_FILE))
        .pipe(debug title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("git-add"))
        .pipe(git.add(options.options))

  ###
    Commits files.

    Arguments:
      - options: object
        * name: string          - task name
        * src: string|array     - glob(s) for files to process (.gitignore files and directories will be ommited)
        * message: string       - commit message (default: --message command line argument or "release")
        * options: object       - git-add options
  ###
  commit: (options = {}) ->
    _.defaults options,
      name: 'git-commit',
      message: argv['message'] or 'release'
    (watch) ->
      gulp.src(options.src)
        .pipe(plumber(errorHandler: common.errorHandler(watch)))
        .pipe(gitIgnore())
        .pipe(filter(IS_FILE))
        .pipe(debug title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("git-commit"))
        .pipe(git.commit(options.message, options.options))

  ###
    Creates release tag.

    Arguments:
      - options: object
        * name: string          - task name
        * src: string           - glob file to use as version source (default: 'package.json')
  ###
  tag: (options = {}) ->
    _.defaults options,
      name: 'git-tag'
      src: 'package.json'
    (watch) ->
      gulp.src(options.src)
        .pipe(plumber(errorHandler: common.errorHandler(watch)))
        .pipe(debug title: common.colors.task("[#{options.name}]") + ' ' + common.colors.action("git-tag"))
        .pipe(tagVersion())

  ###
    Pushes files to a remote Git repository.

    Arguments:
      - options: object
        * name: string          - task name
        * remote: string        - remote to push to (default: --remote command line argument or "origin")
        * branch: string        - branch to push to (default: --branch command line argument or "master")
        * options: object       - git-push options
  ###
  push: (options = {}) ->
    _.defaults options,
      name: 'git-push'
      remote: argv['remote'] or 'origin'
      branch: argv['branch'] or 'master'
      options:
        args: '--tags'
    (watch, cb) ->
      git.push options.remote, options.branch, options.options, cb or (err) ->
        throw err if err?

module.exports = gulpModule
