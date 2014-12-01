gulp    = require 'gulp'
_       = require 'lodash'
del     = require 'del'
chalk   = require 'chalk'
fs      = require 'fs'
open    = require 'open'

smasher = require '../config/global'
project = require '../config/project'
util    = require '../utils/util'
helpers = require '../utils/helpers'

{args, tasks, recipes, commander, assumptions, rootPath, user, platform, project} = smasher
{assets, dir, env} = project
{logger, notify, execute, merge} = util
{files, dest, $, logging, watching} = helpers


### ---------------- COMMANDS ------------------------------------------- ###
smasher.command('docs')
  .description('Generate documentation based on source code')
  .action ->
    tasks.start 'docs'

### ---------------- TASKS ---------------------------------------------- ###
smasher.task 'docs', (done) ->
  # notify "Groc", "Generating documentation..."
  logger.info "Generating documentation in #{chalk.magenta './'+dir.docs}"

  docsGlob = ["README.md"]

  for asset in assets
    docsGlob.push "#{dir.client}/**/*.#{asset}"
    docsGlob.push "#{dir.server}/**/*.#{asset}"

  grocjson = JSON.stringify {
    'glob': docsGlob
    'except': [
      "#{dir.client}/components/vendor/**/*"
    ]
    'github':           false
    'out':              dir.docs
    'repository-url':   smasher.pkg.repository?.url or ''
    'silent':           !args.verbose?
  }, null, 2

  # Dynamically generate .groc.json from config
  fs.writeFile "#{env.configBase}/.groc.json", grocjson, 'utf8', ->
    logger.info "Generated dynamic #{chalk.green '.groc.json'} from project config"  if args.verbose

    # Use our copy of Groc to generate documentation for the project
    require("#{smasher.rootPath}/node_modules/groc").CLI [], (error)->
      process.exit(1) if error
      # notify "Groc", "Success!"
      open "#{dir.docs}/index.html"
      done()

smasher.task 'docs:clean', (done) ->
  if fs.existsSync dir.docs
    logger.info "Deleting #{chalk.magenta './'+dir.docs}"
    del [dir.docs], done
  else
    done()
