PATH = require 'path'
FS   = require 'fs'

VENDOR_ROOT         = PATH.resolve __dirname, 'vendor'
VENDOR_BOOTSTRAP    = PATH.resolve VENDOR_ROOT, 'bootstrap'

exec = (cmds, done) ->
  cmds = [cmds] if 'string' == typeof cmds
  jake.exec cmds, done, { stdout: true, stderr: true }


desc "bootstrap files and package.json for from source"
task 'dist', ['vendor:update'], ->
  console.log 'Generating NPM package...'

  # Copy all LESS files to a 'css' directory
  CSS_DST = PATH.resolve __dirname, 'css'
  CSS_SRC = PATH.resolve VENDOR_BOOTSTRAP, 'less'
  jake.mkdirP CSS_DST
  FS.readdirSync(CSS_SRC).forEach (filename) ->
    return if PATH.extname(filename) != '.less' # skip tests

    # remove implicit loading of variables. apps should do this themselves 
    # so that they can customize them.
    if 'bootstrap.less' == filename or 'responsive.less' == filename
      body = FS.readFileSync PATH.resolve(CSS_SRC, filename), 'utf8'
      body = body.replace /@import "variables.less";.*/g, ''
      FS.writeFileSync PATH.resolve(CSS_DST, filename), body
    else
      jake.cpR PATH.resolve(CSS_SRC, filename), PATH.resolve(CSS_DST, filename)

  # Copy JS files to root - remove prefix
  # Prefix with require for jquery.
  JS_DST = PATH.resolve __dirname, 'plugins'
  JS_SRC = PATH.resolve VENDOR_BOOTSTRAP, 'js'
  jake.mkdirP JS_DST
  FS.readdirSync(JS_SRC).forEach (filename) ->
    return if PATH.extname(filename) != '.js' # skip tests
    body = FS.readFileSync PATH.resolve(JS_SRC, filename), 'utf8'
    body = """
    //
    // Automatically generated from source.
    //

    $ = $ || require('jquery');

    #{body}
    """

    filename = filename.replace(/^bootstrap-/,'') # remove redundancies!
    FS.writeFileSync PATH.resolve(JS_DST, filename), body

  # copy images to img directory
  IMG_DST = PATH.resolve __dirname, 'img'
  IMG_SRC = PATH.resolve VENDOR_BOOTSTRAP, 'img'
  jake.mkdirP IMG_DST
  FS.readdirSync(IMG_SRC).forEach (filename) ->
    jake.cpR PATH.resolve(IMG_SRC, filename), PATH.resolve(IMG_DST, filename)

  # Copy and tweak package.json
  JSON_DST = PATH.resolve __dirname, 'package.json'
  JSON_SRC = PATH.resolve VENDOR_BOOTSTRAP, 'package.json'
  packageJSON = JSON.parse FS.readFileSync(JSON_SRC, 'utf8')
  
  packageJSON.name = "bootstrap-css"
  packageJSON.description = 
    "Asset pipeline compatible version. #{packageJSON.description}"
  packageJSON.keywords.push 'convoy'
  packageJSON.dependencies =
    'jquery': '~1.7',
    'less': 'latest'
    
  packageJSON.maintainers = ['Charles Jolley <charles@sproutcore.com>']
  packageJSON.homepage = "http://github.com/charlesjolley/bootstrap-css"

  delete packageJSON.devDependencies
  delete packageJSON.scripts

  FS.writeFileSync JSON_DST, JSON.stringify(packageJSON, null, 2)

  console.log 'Done.'


namespace 'vendor', ->

  desc "Updates vendor directory to latest version"
  task 'update', (->
    console.log 'updating to latest bootstrap'
    exec "git submodule update", ->
      console.log "Done."
      complete();
  ), async: true
