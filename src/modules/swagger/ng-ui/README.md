swag2
======================

## Prerequisites

+ [Node/NPM](http://nodejs.org/)
+ [Bower](http://bower.io/)
+ [Smashing Dev Tool](https://github.com/smashingboxes/smashing-dev-tool)


## Development

For local setup:

```
git clone git@github.com:smashingboxes/swag2.git
cd swag2
bower install
smash serve
```

This application is being built with the experimental [Smashing Dev Tool](https://github.com/smashingboxes/smashing-dev-tool). Once the dev tool is installed, the following commands are available from within the project repo:

+ `smash compile`: compile the project source into unoptimized HTML, JS and CSS ready for the browser
+ `smash serve`: run a BrowserSync-based development server and re-compile on file changes
+ `smash build`: build the compiled source into a minified, otpimized set of files for deployment
+ `smash docs`: generate a static documentation site for this codebase
+ `smash clean`: remove all generated files (`/compile`, `/build`, `/docs`)
