###
<h1>   Build Configuration   </h1>

Global configuration settings are offloaded to this file
to keep the main Gulpfile clean and succinct.
###
# <br><br><br>
_ =               require 'lodash'
fs =              require 'fs'
path =            require 'path'
join =            path.join

clientDir =       'client'
serverDir =       'server'
compileDir =      'compile'
buildDir =        'build'
deployDir =       'deploy'
docsDir =         'docs'

module.exports =
  timestamp:
    dev: 'YYYYMM'
    qa: 'YYYYMMDD.HHmmss'

  clientDir: clientDir
  serverDir: serverDir
  compileDir: compileDir
  buildDir: buildDir
  deployDir: deployDir

  docsDir: docsDir
  openDocs: true
  openDocsUrl: "#{docsDir}/config/gulpfile.html"
