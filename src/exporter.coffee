fs = require 'fs-extra'
sysPath = require 'path'
marked = require 'marked'

TEMPLATE_DIR = sysPath.join(__dirname, 'template')
HTML_TEMPLATE_FILE = sysPath.join(TEMPLATE_DIR, 'index.html')
HTML_TEMPLATE = fs.readFileSync(HTML_TEMPLATE_FILE, {encoding: 'utf8'})

htmlEscape = (s) ->
  s.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/'/g, '&#39;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

exportNoteAsHTML = (noteDir, outputDir) ->
  meta = JSON.parse(fs.readFileSync(sysPath.join(noteDir, 'meta.json')))
  content = JSON.parse(fs.readFileSync(sysPath.join(noteDir, 'content.json')))
  title = meta.title
  s = ''
  for c in content.cells
    switch c.type
      when 'text'
        s += "<div class='cell text-cell'>#{c.data.replace(/quiver-image-url/gi, 'resources')}</div>"
      when 'code'
        s += "<pre class='cell code-cell'><code>#{htmlEscape(c.data)}</code></pre>"
      when 'markdown'
        s += "<div class='cell markdown-cell'>#{marked(c.data.replace(/quiver-image-url/gi, 'resources'))}</div>"
      when 'latex'
        s += "<div class='cell latex-cell'>#{c.data}</div>"
  html = HTML_TEMPLATE.replace('{{title}}', title).replace('{{content}}', s)

  htmlDir = sysPath.join outputDir, meta.title.replace('/', ':')
  fs.mkdirSync htmlDir unless fs.existsSync(htmlDir)
  fs.writeFileSync sysPath.join(htmlDir, 'index.html'), html

  # Copy resources
  resourcesDir = sysPath.join(noteDir, 'resources')
  if fs.existsSync(resourcesDir)
    fs.copySync resourcesDir, sysPath.join(htmlDir, 'resources')

exportAsHTML = (path, outputDir) ->
  dir = sysPath.resolve(path)
  outputDir ?= process.cwd()

  switch sysPath.extname(dir)
    when '.qvnotebook'
      notebook = JSON.parse(fs.readFileSync(sysPath.join(dir, 'meta.json')))
      outputDir = sysPath.join outputDir, notebook.name.replace('/', ':')
      fs.mkdirSync outputDir unless fs.existsSync(outputDir)

      files = fs.readdirSync(dir)
      for file in files
        noteDir = sysPath.join(dir, file)
        if sysPath.extname(noteDir) is '.qvnote'
          exportNoteAsHTML(noteDir, outputDir)
    when '.qvnote'
      exportNoteAsHTML(dir, outputDir)

module.exports = {exportAsHTML}
