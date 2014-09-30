pkg = require '../package.json'
nomnom = require 'nomnom'
exporter = require './exporter'

opts = nomnom
.script 'quiver2html'
.option 'paths',
  position: 0
  list: true
  required: true
  help: 'Quiver notebook or note file(s)'
.option 'output',
  abbr: 'o'
  help: 'Path to the output directory'
.option 'version',
  abbr: 'v'
  flag: true
  help: 'Print version and exit'
  callback: -> pkg.version
.parse()

for path in opts.paths
  exporter.exportAsHTML path, opts.output
