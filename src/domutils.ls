to-zen = (el) ->
    zen = cssify el.class-name
    if el.children and el.children.length
        "#{zen} > #{to-zen el.children.0}"
    else
        zen

cssify = -> "." + it.split " " .join "."

to-array = -> Array::slice.call it
qs = (node, selector) --> node.query-selector selector
qsa = (node, selector) --> to-array node.query-selector-all selector

module.exports = {
    to-zen
    cssify
    qs
    qsa
}