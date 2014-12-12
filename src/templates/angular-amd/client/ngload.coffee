#jslint node: true, vars: true, nomen: true

#globals define
'use strict'
define load: (name, req, onload, config) ->

  #console.log('ngamd loaded: ', req.toUrl(name))
  req ['angularAMD', name], (angularAMD, value) ->

    #console.log('Processing queues.')
    angularAMD.processQueue()
    onload value

