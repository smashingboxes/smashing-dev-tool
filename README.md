# Smashing Dev Tool

This is a WIP CLI for Smashing Boxes, focusing on frontend tooling and automation. By following the conventions this tool is built on, you can instantly add front end tooling and dev ops goodness to any Smashing project. Tell smasher which asset types you want to include in your Smashfile and it will build a data model of your source code that can be manipulated and queried by other modules.

## Prerequisites

+ [Node/NPM](http://nodejs.org/)
+ [Bower](http://bower.io/)

## Installation (Beta Instructions)
smashing-dev-tool is available via the NPM registry. It currently depends on Bower and CoffeeScript gobally.

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

## Example Smashfile

In each project the `smashfile.coffee` file contains local config used by smashing-dev-tool to compile/build/document front-end assets. Default assumptions made by the tool can be overridden here on a project specific basis. 

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
+ ~~Compile and build source code (replaces Rails Asset Pipeline)~~
+ Automated testing of source code (unit, e2e)
+ ~~Documentation generation from source (via Groc)~~
+ ~~Project generation and scaffolding (a la Yeoman)~~
+ Component guide generation
+ API mocking, test data generation
+ UI/UX deliverables generated from source code (style tiles, etc.)
