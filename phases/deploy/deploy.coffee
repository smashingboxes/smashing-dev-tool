gulp =            require 'gulp'
$ =               require('gulp-load-plugins')(camelize: true)  # attach  "gulp-*" plugins to '$' variable
runSequence =     require 'run-sequence'

cfg =             require '../build.config'
helpers =         require('./helpers')
{
  files
  copyFiles
  vendorFiles
  time
  filters
  dest
  execute
  colors
  log
  notify

  isQa
  isVerbose
  isBundled
  isOptimized
  base64Images
  isWatching

  currentDir
  USER
  APP_NAME
  BUILD_TIME
  APP_VERSION_SRC
  APP_VERSION
  APP_VERSION_AS_URL
  STACKATO_APP_ID
} = helpers

# <br><br><br>


###
<h2>Ant Tasks</h2>
Until Java is replaced by Node as the default web server, `build.xml` remains
the simplest way to build the Java WAR required by the current infrastructure.

These tasks create a Java WAR to be deployed to the Stackato platform: <br><br>

1. Build client assets
2. remove old WAR
3. copy common files into WAR directory
4. compile JAVA and build WAR
5. cleanup leftover files
<br><br>
###

### Paths pointing to other Apollo/common assets ###
basedir =             '.'
APOLLO_BASE_DIR =     "#{process.env.APOLLO_BASE_DIR}"
STAGING_ROOT =        "#{basedir}/#{cfg.deployDir}"
STAGING_DIR =         "#{STAGING_ROOT}/stackato"
COMMON_DIR =          "#{APOLLO_BASE_DIR}/common"
AGENT_DIR =           "#{APOLLO_BASE_DIR}/Agent/dist/jnlp"
WAR_DIR =             "#{STAGING_DIR}/war"
WEB_INF =             "#{basedir}/config/WEB-INF"
WEBCONTENT =          "#{WAR_DIR}"
STACKATO_DIR =        "#{COMMON_DIR}/stackato"
COMMON_LIB_DIR =      "#{COMMON_DIR}/server/lib/common"
BUILD_LIB_DIR =       "#{COMMON_DIR}/server/lib/build"
COMMON_SRC =          "#{COMMON_DIR}/server/src"

###
**war** <br>
Build WAR for deployment
###
gulp.task 'war', (done) ->
  notify "Deploy", 'Creating WAR archive...'
  runSequence(
    'war:clean'
    'war:prep'
    'war:build'
    'war:cleanup'
    ->
      notify "Deploy", "Archive created!"
      done()
  )

###
**war:clean** <br>
Delete the previous WAR
###
gulp.task 'war:clean', ->
  $.util.log 'deleting staging root' if isVerbose
  gulp.src "#{STAGING_ROOT}"
    .pipe $.rimraf cfg.tasks.rimraf

###
**war:prep** <br>
Copy source files for WAR into a staging directory
###
gulp.task 'war:prep', (done) ->
  warfiles = [
    {src: "#{cfg.serverDir}/logback.xml",            dest: "#{cfg.deployDir}/stackato/war/WEB-INF/classes"}
    {src: "config/WEB-INF/**",                       dest: "#{cfg.deployDir}/stackato/war/WEB-INF"}
    {src: "#{COMMON_LIB_DIR}/*jar",                  dest: "#{WEB_INF}/lib/"}
    {src: "#{cfg.buildDir}/**/*",                    dest: "#{WEBCONTENT}"}
    {src: "#{AGENT_DIR}/**/*",                       dest: "#{WEBCONTENT}/appletJnlp"}
    {src: "#{STACKATO_DIR}/installAppWebContent.sh", dest: "#{WAR_DIR}"}
    {src: "#{STACKATO_DIR}/appInstall.js",           dest: "#{WAR_DIR}"}
    {src: "#{basedir}/appDescriptor.json",           dest: "#{WAR_DIR}",  replace: [/@APP_VERSION@/g, "#{APP_VERSION}"] }
  ]
  copyFiles(warfiles)
  done()

###
**war:build** <br>
Compile Java and build the WAR via existing Ant configuration
###
gulp.task 'war:build', (done) ->
  execute "ant -DAPP_NAME=#{APP_NAME} -DAPP_VERSION_AS_URL=#{APP_VERSION_AS_URL} makeWar", done

###
**war:cleanup** <br>
Remove leftover files generated in the build
###
gulp.task 'war:cleanup', ->
  gulp.src "#{STAGING_DIR}/war"
    .pipe $.rimraf(cfg.tasks.rimraf)
# <br><br><br>





###
<h2>Stackato Tasks</h2>
###

###
**update** <br>
Update deployed instance of this app
###
gulp.task 'stackato:update', (done) ->
  notify 'Deploy', 'Updating existing instance...'
  execute "stackato update -n --path #{cfg.deployDir}/stackato", ->
    notify 'Deploy', 'Success!'
    done()
# <br><br><br>


###
**push** <br>
Deploy this app for the first time
###
gulp.task 'stackato:push', (done) ->
  notify 'Deploy', 'Creating new instance...'
  execute "stackato push -n --path #{cfg.deployDir}/stackato", ->
    notify 'Deploy', 'Success!'
    done()
# <br><br><br>


gulp.task 'app:delete', (done) ->
  execute "stackato delete #{STACKATO_APP_ID}", done

gulp.task 'app:start', (done) ->
  execute "stackato start #{STACKATO_APP_ID}",  done

gulp.task 'app:stop', (done) ->
  execute "stackato stop #{STACKATO_APP_ID}", done

gulp.task 'app:list', (done) ->
  execute "stackato apps | grep #{APP_NAME}", done




gulp.task 'clean:deploy', ->
  gulp.src cfg.deployDir
    .pipe $.rimraf cfg.tasks.rimraf
