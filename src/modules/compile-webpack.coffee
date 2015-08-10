gulp             = require 'gulp'
gutil            = require 'gulp-util'
_                = require 'lodash'
del              = require 'del'
chalk            = require 'chalk'
fs               = require 'fs'
q                = require 'q'
webpack          = require 'webpack'
webpackStream    = require 'webpack-stream'
WebpackDevServer = require 'webpack-dev-server'
open             = require 'open'


module.exports = (Smasher) ->
  {recipes, commander, recipes,  project, util, helpers} = Smasher
  {logger, notify, execute, merge, args} = util
  {files, $, dest, logging,rootPath, pkg} = helpers
  {dir, assets, supportedAssets} = project

  # configFile = fs.readFileSync("#{project.env.cwd}/webpack.config.js")
  webpackConfig = _.merge project.webpack,
    context: process.cwd()
    # resolve:
    #   modulesDirectories: [ ]
    #   root: [
    #     "#{helpers.rootPath}/node_modules"
    #     "#{project.env.cwd}/node_modules"
    #   ]
    resolveLoader:
      modulesDirectories: [
        "#{helpers.rootPath}/node_modules"
        "#{project.env.cwd}/node_modules"
      ]
    module:
      loaders: [
        test: /\.css$/, loader: "style!css"
      ]
    devtool: 'sourcemap'
    debug:   true
    output:
      path: "#{project.env.cwd}/build"
      publicPath: "/"
      filename: 'bundle.js'

  wp = -> webpack webpackConfig

  compile = ->
    wp().run (err, stats) ->
      if err
        throw new (gutil.PluginError)('webpack:compile', err)
      gutil.log '[webpack:compile]', stats.toString(colors: true)

  build = ->
    _.extend webpackConfig,
      plugins: [
        new (webpack.DefinePlugin)(
          'process.env':
            'NODE_ENV': JSON.stringify 'production'
        )
        new (webpack.optimize.DedupePlugin)
        new (webpack.optimize.UglifyJsPlugin)
      ]
    compile()

  watch = ->
    _.extend webpackConfig,
      devtool: 'eval'
      debug: true

    # Start a webpack-dev-server
    console.log webpackConfig.output.publicPath
    new WebpackDevServer(wp(),
      publicPath: "#{webpackConfig.output.publicPath}"
      hot: true
      stats:
        colors: true
    ).listen 8080, 'localhost', (err) ->
      if err
        throw new (gutil.PluginError)('webpack:serve', err)
      gutil.log '[webpack:serve]', 'http://localhost:8080/webpack-dev-server/index.html'
      # open 'http://localhost:8080/webpack-dev-server/index.html'


  ## ---------------- COMMANDS ------------------------------------------- ###
  Smasher.command
    cmd: 'webpack'
    options: [
      opt: '-c --cat'
      description: 'Output injected index file for inspection'
    ]
    description: 'compile local assets based on Smashfile'
    action: (target) ->
      logger.info "Building #{chalk.blue 'Webpack'} bundle from entry point '#{chalk.magenta webpackConfig.entry}'"

      switch target
        when 'build' then build()
        when 'compile' then compile()
        when 'watch' then watch()
        else compile()

  ### ---------------- TASKS ---------------------------------------------- ###
  # Development build (compile)
  Smasher.task 'webpack:compile', compile

  # Production build
  Smasher.task 'webpack:build', build

  # Development server
  Smasher.task 'webpack:serve', watch
