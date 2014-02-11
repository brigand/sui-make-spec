require 'shelljs/global'
require! path
require! \js-yaml
require! jsdom
{filter, map} = require \prelude-ls

handlers = 
    elements: require './src/elements.ls'
    collections: require './src/collections.ls'
    modules: require './src/modules.ls'

# Some initial setup
cd __dirname
dirs = filter (of handlers), ls \input
rm \-rf, \build
mkdir \build
map (-> mkdir out-dir-for it), dirs
    
# We want to recurse into each directory and process each file
data = process-dir \elements

function process-dir dir 
    console.log "#{dir}:"
    ls(dir-for dir).map(path.basename).for-each (file-name) ->
        description = process dir, file-name
        JSON.stringify(description, null, 4).to(out-dir-for dir, file-name)

function process type, file
    console.log " - #{file} to #{out-dir-for type, file}"
    file = cat dir-for type, file

    [_, yaml, html] = file.split /---/g, 3

    meta-data = js-yaml.safe-load yaml

    # Remove everything before this
    clean-html = html.slice html.index-of '<div class="main container">'

    document = jsdom.jsdom "<html><head></head><body>#{clean-html}</body></html>"
    main-data = handlers[type](document, "ui #{meta-data.css}")

    all-data = {
        Name: "Semantic #{meta-data.title}"
        Description: meta-data.description
        Definition: pascal-case type
    } <<< main-data
    

function dir-for name, file="*.html.eco"
    path.relative __dirname, path.join "input", name, file

function out-dir-for name, file=""
    if file
        file = file.split(".").0 + ".json"
    path.relative __dirname, path.join \build, name, file

function pascal-case text
    words = text.split " " .map ->
        it.0.to-upper-case! + it.slice 1 .to-lower-case!

    words.join ""
