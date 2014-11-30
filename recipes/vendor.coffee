through2       = require 'through2'
gulp           = require 'gulp'
bowerRequireJS = require 'bower-requirejs'
smasher = require '../config/global'

smasher.recipe
  name:   'vendor'
  ext:    'vendor'
  type:   'vendor'
  doc:    false
  test:   true
  lint:   false
  reload: true
