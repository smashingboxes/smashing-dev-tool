###
[imacss](https://github.com/akoenig/imacss) is an application and library that transforms image
files to [data URIs (rfc2397)](http://www.ietf.org/rfc/rfc2397.txt)
and embeds them into a single CSS file as background images.
###
imacss: 'images.css'

imagemin:
  progressive: true






###
<h2>Images</h2>
###

# _optimizeImages_
optimizeImages = lazypipe()
  .pipe $.imagemin, cfg.tasks.imagemin

# _encodeImages_
encodeImages = lazypipe()
  .pipe $.imacss, cfg.tasks.imacss

gulp.task 'build:images', ->
  log.tag 'build', 'images'
  files('gif', 'jpg', 'png', 'svg')
    .pipe $.if isVerbose, $.using()
    .pipe optimizeImages()
    # .pipe $.if base64Images, encodeImages()
    .pipe dest.build()
# <br><br><br>
