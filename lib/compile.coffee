
args         = require('minimist')(process.argv.slice 2)
fs = require 'fs'
vfs = require 'vinyl-fs'
map = require 'map-stream'
accord = require 'accord'
gutil = require 'gulp-util'
through = require 'through2'
chalk = require 'chalk'


path = require 'path'
PluginError = gutil.PluginError


winston     = require 'winston'
winston.cli()
log = new (winston.Logger)(
  transports: [new (winston.transports.Console)(colorize: true, level: (if args.verbose then 'verbose' else 'info'))]
  levels:
    silly: 0
    verbose: 1
    info: 2
    data: 3
    warn: 4
    debug: 5
    error: 6
  colors:
    silly: 'magenta'
    verbose: 'cyan'
    info: 'green'
    data: 'grey'
    warn: 'yellow'
    debug: 'blue'
    error: 'red'
)


getCompiler = (ext) ->
  lookup =
    '.coffee':   'coffee-script'
    '.styl':     'stylus'
    '.md':       'markdown'
    '.haml':     'haml'
    '.swig':     'swig'
    '.mustache': 'mustache'
    '.hbs':      'handlebars'
  staticAssets = [
    'html'
    'js'
    'css'
    'json'
  ]

  engine = lookup[ext] or ext.replace('.', '')
  unless accord.supports engine
    if engine in staticAssets
      log.verbose 'got a static asset!'
      static: true
    else
      log.error "Could not resolve asset: #{engine}"
  else
    accord.load engine

compile = (ext, opt) ->
  compiler = getCompiler ext
  if compiler?.static
    log.info "Copying [#{chalk.bgRed ext}]"
    through.obj (file, enc, cb) ->
      log.info chalk.bgBlue file.path
      cb(null, file)

  else if compiler
    log.info "Compiling [#{chalk.bgRed ext}] ⇒ [#{chalk.bgMagenta compiler.output}]"
    through.obj (file, enc, cb) ->
      if file.isNull() or file.extname isnt ext
        return cb(null, file)
      if file.isStream()
        return cb(new PluginError('gulp-coffee', 'Streaming not supported'))

      str  = file.contents.toString('utf8')
      dest = gutil.replaceExtension(file.path, ".#{compiler.output}")

      compiler.render(str).done (res) ->
        log.info chalk.bgBlue dest
        data = res.result.toString()
        file.path = dest
        file.contents = new Buffer(data)
        cb(null, file)

  else
    through.obj (file, enc, cb) ->
      cb(null, file)

getCompilerD = (ext, lib) ->
  (opt) ->
    compiler = accord.load lib
    log.info "Compiling [#{chalk.bgMagenta compiler.output}] using #{chalk.red lib}"
    through.obj (file, enc, cb) ->
      if file.isNull() or file.extname isnt ext
        return cb(null, file)
      str  = file.contents.toString('utf8')
      dest = gutil.replaceExtension(file.path, ".#{compiler.output}")
      compiler.render(str).done (res) ->
        log.info (chalk.bgMagenta "[#{lib}] ") + chalk.bgBlue dest
        data = res.result.toString()
        file.path = dest
        file.contents = new Buffer(data)
        cb(null, file)


ngHtml2Js = require 'gulp-html2js'
css2Js    = require 'gulp-css2js'
cat       = require 'gulp-cat'
concat    = require 'gulp-concat'
using     = require 'gulp-using'

postcss    = getCompilerD '.css',  'postcss'
babel      = getCompilerD '.js',   'babel'

minifyJs   = getCompilerD '.js',   'minify-js'
minifyHtml = getCompilerD '.html', 'minify-html'
minifyCss  = getCompilerD '.css',  'minify-css'
csso       = getCompilerD '.css',  'csso'


filter = require 'gulp-filter'

fStyles  = filter '**/*.{styl,scss,less,css}',     restore: true
fViews   = filter '**/*.{jade,md,swig,haml,html}', restore: true
fScripts = filter '**/*.{js,coffee,jsx}',          restore: true


compileAll = (opt) ->

  pipeline = vfs.src [
    opt.dir.in
  ]
    .pipe fStyles
    .pipe compile('.styl', {})
    .pipe compile('.scss', {})
    .pipe compile('.less', {})
    .pipe compile('css',   {})
    .pipe postcss({})
    .pipe minifyCss({})
    .pipe concat 'styles.css'
    .pipe css2Js()
    .pipe fStyles.restore

    .pipe fViews
    .pipe compile('.jade', {})
    .pipe compile('.md',   {})
    .pipe compile('.swig', {})
    .pipe compile('.haml', {})
    .pipe compile('.html')
    .pipe minifyHtml({})
    .pipe ngHtml2Js()
    .pipe concat 'views.js'
    .pipe fViews.restore

    .pipe fScripts
    .pipe compile('.coffee', {})
    .pipe compile('.jsx',    {})
    .pipe compile('.js',     {})
    .pipe babel({})
    .pipe minifyJs({})
    .pipe concat('scripts.js')
    .pipe fScripts.restore
    .pipe using()

    .pipe vfs.dest(opt.dir.out)




module.exports = (vantage) ->
  vantage
    .command 'compile'
    .description 'Compiles assets'
    .action (args, cb) ->
      compileAll(
        dir:
          in: './_testfiles/**/*'
          out: './out'
      ).on 'finish', cb
