# Smashing Dev Tool

This is a WIP CLI for Smashing Boxes, focusing on frontend tooling and automation. By following the conventions this tool is built on, you can instantly add front end tooling and dev ops goodness to any Smashing project. Tell smasher which asset types you want to include in your Smashfile and it will build a data model of your source code that can be manipulated and queried by other modules.

## Prerequisites

+ [Node + NPM](http://nodejs.org/)
+ [Bower](https://www.npmjs.com/package/bower)
+ [CoffeeScript](https://www.npmjs.com/package/coffee-script)

## Installation
`smashing-dev-tool` is available via the NPM registry. It currently depends on Bower and CoffeeScript globally.

```
  $ npm install -g coffee-script bower smashing-dev-tool
```

The `smash` command should now be available globally. Some commands are only available from inside a project with a valid `smashfile.coffee`.



## Available Commands

### Global
+ `smash new <some-project-name>`: generate a new `smashing-dev-tool`-compatible project in a folder called "<some-project-name>" and `bower install` dependecies for the chosen template

### Per-project

+ `smash compile`: compile the project source into unoptimized HTML, JS and CSS ready for the browser
+ `smash serve`: run a BrowserSync-based development server and re-compile on file changes
+ `smash build`: build the compiled source into a minified, otpimized set of files for deployment
+ `smash docs`: generate a static documentation site for this codebase
+ `smash clean`: remove all generated files (`/compile`, `/build`, `/docs`)
+ `smash bump [patch|minor|major|prerelease]`: bump the version by the specified importance level and tag the repo (reuqires a `git init`'d project repo)



# `smash`-able Projects

## Project Generation

**Command**: `smash new <project-name>`

Smashing Dev Tool borrows from the [Slush](http://slushjs.github.io/) project to allow for straight-forward, stream-based scaffolding from templates. A template consists of a list of questions contained in `prompts.json`, a `bower.json` manifest containing dependencies needed by the template, and a `smashfile.coffee` that has initial configuration used by the tool. The remaining files in a template have no restrictions, but should conform to the default Smashing Dev Tool folder assumptions, unless they are overridden in the included `smashfile.coffee`.

During project generation, user input is gathered from the commandline and inserted into the template files using [gulp-template](https://github.com/sindresorhus/gulp-template). Variables can be used in template files as follows:

`prompts.json`:
```json
[
  {
    "name": "appName",
    "message": "What is the name of your project?",
    "default": "Sample Application"
  },
  {
    "name": "appDescription",
    "message": "What is the description?",
    "default": "A sample application."
  }
]
```

`client/index.jade`:
```jade
doctype html
head
  title <%= appNameSlug %>

body
  div.container
    h1 <%= appName %>
    p <%= appDescription %>
```

Files prefixed with an `_` will be copied to the destination as dotfiles (`_bowerrc` -> `.bowerrc`) in the generated project. All other files will be copied directly, preserving directory structure and replacing template tags with the appropriate values. After generation, [gulp-install](https://github.com/slushjs/gulp-install) will run `bower install` and/or `npm install` inside the project directory. [gulp-conflict](https://github.com/slushjs/gulp-conflict) will prompt the user for action if the project directory contains file conflicts.

_**Note**: at minimum, `appName` is required in `prompts.json` to create a project_

_**Note**: the variable `appNameSlug` is a hyphen-delimited version of `appName` automatically generated and available for use within your templates._


## Compling Code

**Command**: `smash compile`

The compile phase transforms code located in `/client` into browser-ready code located in `/compile`. Preprocessors are run against files with the appropriate extensions (`.coffee`, `.jade`, `.styl`, `.scss`, etc.)






## Documentation Generation
**Command**: `smash docs`

Smashing Dev Tool currently uses [Groc](https://github.com/nevir/groc) to generate a static documentation site in `<project-folder>/docs`. A `.groc.json` file will be dynamically generated each time the command is run and contains settings required for Groc. These settings are based on the local `bower.json` and settings in `smashfile.coffee`.


## Example Smashfile

In each project the `smashfile.coffee` file contains local config used by smashing-dev-tool to compile/build/document client-side assets. Default assumptions made by the tool can be overridden here on a per-project basis.

```
module.exports =

  # file types to be compiled/built
  assets: [
    'coffee'
    'css'
    'styl'
    'jade'
    'json'
  ]

  # override default directory conventions
  dir:
    client: 'WebContent'
    server: 'src'
```


## TODO/Future
+ Automated testing of source code (unit, e2e)
+ Component guide generation
+ API mocking, test data generation
+ UI/UX deliverables generated from source code (style tiles, etc.)
