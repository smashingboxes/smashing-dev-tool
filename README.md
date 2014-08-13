# Smashing Dev Tool

This is a WIP CLI for Smashing Boxes, focusing on frontend tooling and automation. By following the conventions this tool is built on, you can instantly add front end tooling and dev ops goodness to any Smashing project. Tell Smasher which asset types you want to include in your Smashfile and it will build a data model of your source code that can be manipulated and queried by other modules.



## Installation

`npm install smasher`



## Example Smashfile

```coffeescript
  module.exports =
    assets: [
      'html'
      'jade'
      'css'
      'styl'
      'js'
      'coffee'
      'json'
      {name: 'python', ext: 'py', type: 'data', doc: false, test: false, lint: false}
    ]
    dir:
      client: 'WebContent'
      server: 'src'
```

## TODO/Future

+ testing
+ documentation generation from source (via Groc)
+ project generation and scaffolding (a la Yeoman)
+ component guide generation
+ UI/UX deliverables generated from source code (style tiles, etc.)
+ provisioning of dev resorces (DigitalOcean, GitHub, AWS)
