###
* This is an example build file that demonstrates how to use the build system for
* require.js.
*
###

module.exports =
  ###
    By default, all modules are located relative to this path. If baseUrl
    is not explicitly set, then all modules are loaded relative to
    the directory that holds the build file. If appDir is set, then
    baseUrl should be specified as relative to the appDir.
  ###

  baseUrl: "compile"

  ###
    By default all the configuration for optimization happens from the command
    line or by properties in the config file, and configuration that was
    passed to requirejs as part of the app's runtime "main" JS file is *not*
    considered. However, if you prefer the "main" JS file configuration
    to be read for the build so that you do not have to duplicate the values
    in a separate configuration, set this property to the location of that
    main JS file. The first requirejs({}), require({}), requirejs.config({}),
    or require.config({}) call found in that file will be used.
    As of 2.1.10, mainConfigFile can be an array of values, with the last
    value's config take precedence over previous values in the array.
  ###
  mainConfigFile: "compile/main.js"


  #If you only intend to optimize a module (and its dependencies), with
  #a single file as the output, you can specify the module options inline,
  #instead of using the 'modules' section above. 'exclude',
  #'excludeShallow', 'include' and 'insertRequire' are all allowed as siblings
  #to name. The name of the optimized file is specified by 'out'.
  name: "app"
  # include: ["foo/bar/bee"]
  # insertRequire: ["foo/bar/bop"]
  out: "app.js"
  removeCombined: true



  #Sets the logging level. It is a number. If you want "silent" running,
  #set logLevel to 4. From the logger.js file:
  #TRACE: 0,
  #INFO: 1,
  #WARN: 2,
  #ERROR: 3,
  #SILENT: 4
  #Default is 0.
  logLevel: 0
