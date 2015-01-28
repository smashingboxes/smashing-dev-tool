###

<h2>Recursive hierarchical structure</h2>
We propose a recursive structure, the base unit of which contains a module definition file (app.js), a controller definition file (app-controller.js), a unit test file (app-controller_test.js), an HTML view (index.html or app.html) and some styling (app.css) at the top level, along with directives, filters, services, protos, e2e tests, in their own subdirectories.


<h2>Components and Sub-sections</h2>
We group elements of an application either under a "components" directory (for common elements reused elsewhere in the app), or under meaningfully-named directories for recursively-nested sub-sections that represent structural "view" elements or routes within the app:


<h3>Components</h3>

+ A components directory contains directives, services, filters, and related files.
+ Common data (images, models, utility files, etc.) might also live under components (e.g. components/lib/), or it can be stored externally.
+ Components can have subcomponent directories, including appended naming where possible.
+ Components may contain module definitions, if appropriate. (See "Module definitions" below.)


<h3>Sub-sections</h3>

+ These top-level (or nested) directories contains only templates (.html, .css), controllers, and module definitions.
+ We stamp out sub-level child sub-sections using the same unit template (i.e., a section is made up of templates, controllers, and module definitions), going deeper and deeper as needed to reflect the inheritance of elements in the UI.
+ For a very simple app, with just one controller, sub-section directories might not be needed, since everything is defined in the top-level files.
+ Sub-sections may or may not have their own modules, depending on how complex the code is.  (See "Module definitions" below.)


<h3>Module definitions</h3>

+ In general, 'angular.module('foo')' should be called only once. Other modules and files can depend on it, but they should never modify it.
+ Module definition can happen in the main module file, or in subdirectories for sections or components, depending on the application's needs.


<h3>Naming conventions</h3>

We lean heavily on the Google JavaScript Style Guide naming conventions and propose a few additions:
+ Each filename should describe the file's purpose by including the component or view sub-section that it's in, and the type of object that it is as part of the name. For example, a datepicker directive would be in components/datepicker/datepicker-directive.js.
+ Controllers, Directives, Services, and Filters, should include controller, directive, service, and filter in their name.
+ File names should be lowercase, following the existing JS Style recommendations. HTML and css files should also be lowercase.
+ Unit tests should be named ending in _test.js, hence  "foo-controller_test.js" and "bar-directive_test.js"
+ We prefer, but don't require, that partial templates be named something.html rather than something.ng. (This is because, in practice, most of the templates in an Angular app tend to be partials.)

###



# Supported asset types
# exports.assets = require './assets'


module.exports =
  name: 'assumptions'
  attach: ->
    @assumptions =
      test:
        prefix: 'test_'

      # Directory names
      dir:
        client:  'client'
        server:  'server'

        vendor:  'client/components/vendor'

        compile: 'compile'
        build:   'build'
        deploy:  'deploy'

        docs:    'docs'

      # Compile stage defaults
      compile:
        html2js: false

      # Build stage defaults
      build:
        styles:  'app.css'
        views:   'app-views.js'
        scripts: 'app.js'
