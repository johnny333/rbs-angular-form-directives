gulp         = require 'gulp'
path         = require 'path'
childProcess = require 'child_process'

protractorBinary = (name) ->
    winExt = if /^win/.test process.platform
      '.cmd'
    else
      ''
    pkgPath = require.resolve 'protractor'
    protractorDir = path.resolve path.join(path.dirname(pkgPath), '..', 'bin')
    path.join protractorDir, '/' + name + winExt

protractorInstall = (done) ->
    childProcess.spawn(protractorBinary('webdriver-manager'), ['update'], stdio: 'inherit').once('close', done)

protractorRun = (args = []) ->
  (done) ->
    childProcess.spawn(protractorBinary('protractor'), args, stdio: 'inherit').once('close', done)

module.exports =
  installTask: protractorInstall
  runTask: protractorRun
