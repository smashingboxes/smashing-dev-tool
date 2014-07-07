
###
**<h5>[gulp-csso](https://github.com/ben-eb/gulp-csso)</h5>**

CSSO (CSS Optimizer) is a CSS minimizer unlike others. In addition
to usual minification techniques it can perform structural optimization
of CSS files, resulting in smaller file size compared to other minifiers.
See more detailed information [here](http://ru.bem.info/tools/optimizers/csso/)
###
csso: false # set to true to prevent structural modifications
# <br><br><br>


###
**<h5>[gulp-css2js](https://github.com/tests-always-included/gulp-css2js)</h5>**
<em>Wrapper for <strong><a href="https://github.com/grnadav/css2js">css2js</a></strong></em>

Convert CSS into a self-executing function that injects a `<style>` element
into the `<head>` of the document.
###
css2js:
  splitOnNewline: true
  trimSpacesBeforeNewline: true
  trimTrailingNewline: true


###
**<h5>[gulp-myth](https://github.com/sindresorhus/gulp-myth)</h5>**
<em>Wrapper for <strong><a href="https://github.com/segmentio/myth">Myth</a></strong></em>

Myth lets you write pure CSS while still giving you the benefits of tools
like LESS and Sass. You can still use variables and math functions, just
like you do in preprocessors. It's like a polyfill for future versions of
the spec.
###
myth:
  sourcemap: false
  # browsers: []
# <br><br><br>




###
<h2>Styles</h2>
###

# add polyfills, 3rd-pary libs
postProcessStyles = lazypipe()
  .pipe $.myth, cfg.tasks.myth

# minify .css
optimizeStyles = lazypipe()
  .pipe $.csso, cfg.tasks.csso

# convert .css to .js for self-injecting style element
bundleStyles = lazypipe()
  .pipe $.concat, 'app-styles.css'
  .pipe $.css2js
  .pipe $.wrapAmd

gulp.task 'build:styles', ->
  log.tag 'build', 'styles'
  compiledFiles('css')
    .pipe $.if isVerbose, $.using()
    .pipe optimizeStyles()
    .pipe bundleStyles()
    .pipe $.if isVerbose, $.using()
    .pipe dest.build()
