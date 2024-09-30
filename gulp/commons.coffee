chalk = require 'chalk'
gutil = require 'gulp-util'
match = require 'gulp-match'

# sourcemaps glob
IS_SOURCEMAP     = '**/*.map'

isSourcemapFile = (file) -> match(file, IS_SOURCEMAP)

isNotSourcemapFile = (file) -> not isSourcemapFile(file)

errorHandler = (watch) ->
  if watch
    (err) ->
      gutil.log err
      this.emit('end')
  else true

module.exports =
  errorHandler: errorHandler
  predicates:
    isSourcemapFile: isSourcemapFile
    isNotSourcemapFile: isNotSourcemapFile
  colors:
    file: chalk.blue
    task: chalk.bold.green
    action: chalk.cyan
    warning: chalk.yellow
    error: chalk.red
