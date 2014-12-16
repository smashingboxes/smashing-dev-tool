"use strict"
through = require("through2")
gutil = require("gulp-util")
module.exports = filelog = (taskParam) ->
  decorate = (color, text) ->
    (if text then "[" + gutil.colors[color](text) + "]" else "")
  count = 0
  through.obj ((file, enc, callback) ->
    items = []
    count++
    items.push decorate("blue", taskParam)  if taskParam
    items.push decorate("yellow", count)
    items.push decorate("cyan", file.path)
    items.push decorate("magenta", "EMPTY")  if file.isNull()
    gutil.log items.join(" ")
    @push file
    callback()
  ), (cb) ->
    task = (if taskParam then decorate("blue", taskParam) + " " else "")
    gutil.log task + "Found " + decorate("yellow", count.toString()) + " files."
    cb()
    return
