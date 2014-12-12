# Smashing Dev Tool

This is a WIP CLI for Smashing Boxes, focusing on frontend tooling and automation. By following the conventions this tool is built on, you can instantly add front end tooling and dev ops goodness to any Smashing project. Tell smasher which asset types you want to include in your Smashfile and it will build a data model of your source code that can be manipulated and queried by other modules.



## Installation (Alpha Instructions)

For now, the easiest way to use this tool is via `npm link`. Eventually it will be installable via the public NPM registry.

First clone this repository somewhere on your machine, `cd` to that directory and run `npm link`:

```
  $ git clone git@github.com:smashingboxes/smashing-dev-tool.git
  $ cd smashing-dev-tool
  $ npm link
```

This will make the contents of the folder available as a globally installed NPM plugin. Running `git pull` in this directory will update the tool.

The 'smash' command should now be available globally.


## Example Smashfile

```coffeescript
  module.exports =
    # file types to be compiled/built
    assets: [
      'html'
      'jade'
      'css'
      'styl'
      'js'
      'coffee'
      'json'

      # define additional asset types that are not built-in
      {name: 'python', ext: 'py', type: 'data', doc: false, test: false, lint: false}
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
+ Provisioning of dev resources (DigitalOcean, GitHub, AWS)
