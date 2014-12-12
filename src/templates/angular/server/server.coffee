#!/usr/bin/env coffee
httpServer = require 'http-server'
exec = require 'exec'

# httpServer.createServer()

exec ['http-server', '-a ./client', '-p 8000'], (err, out, code) ->
  console.log err, out, code
