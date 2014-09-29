pkg = require '../package.json'
nomnom = require 'nomnom'
exporter = require './exporter'

opts = nomnom
.script 'quiver2html'
.option 'output',
  abbr: 'o'
  full: 'output'
  help: 'Path to the output dir'
.option 'version',
  abbr: 'v'
  full: 'version'
  flag: true
  help: 'Print version and exit'
  callback: -> pkg.version
.parse()

for path in opts._
  exporter.exportAsHTML path, opts.output
