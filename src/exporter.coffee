fs = require 'fs-extra'
sysPath = require 'path'
marked = require 'marked'

TEMPLATE_DIR = sysPath.join(__dirname, 'template')
HTML_TEMPLATE_FILE = sysPath.join(TEMPLATE_DIR, 'index.html')
HTML_TEMPLATE = fs.readFileSync(HTML_TEMPLATE_FILE, {encoding: 'utf8'})

htmlEscape = (s) ->
  s.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/'/g, '&#39;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

exportAsHTML = (path, outputDir) ->
  dir = sysPath.resolve(path)

  switch sysPath.extname(dir)
    when '.qvnotebook'
      console.log 'qvnotebook'
    when '.qvnote'
      meta = JSON.parse(fs.readFileSync(sysPath.join(dir, 'meta.json')))
      content = JSON.parse(fs.readFileSync(sysPath.join(dir, 'content.json')))
      title = meta.title
      s = ''
      for c in content.cells
        switch c.type
          when 'text'
            s += "<div class='cell text-cell'>#{c.data.replace(/quiver-image-url/gi, 'resources')}</div>"
          when 'code'
            s += "<pre class='cell code-cell'><code>#{htmlEscape(c.data)}</code></pre>"
          when 'markdown'
            s += "<div class='cell markdown-cell'>#{marked(c.data)}</div>"
      html = HTML_TEMPLATE.replace('{{title}}', title).replace('{{content}}', s)

      outputDir ?= process.cwd()
      noteDir = sysPath.join(outputDir, "#{meta.title}")
      fs.mkdirSync noteDir unless fs.existsSync(noteDir)
      fs.writeFileSync sysPath.join(noteDir, 'index.html'), html

      # Copy resources
      if fs.existsSync(sysPath.join(dir, 'resources'))
        fs.copySync sysPath.join(dir, 'resources'), sysPath.join(noteDir, 'resources')

module.exports = {exportAsHTML}
