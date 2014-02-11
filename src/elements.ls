{map, each} = require \prelude-ls
{to-zen, cssify, qs, qsa} = require "./domutils.ls"

module.exports = (document, base-class) ->
    root = document.query-selector(\.main.container)
    Definitions = {}
    output = {}
    context = ""

    process = (node) ->
        find = qs node
        find-all = qsa node

        if node.class-name is "ui dividing header"
            context := node.text-content
            output[context] = {}
        else if node.class-name is "example"
            name = find \h4 .text-content
            Definitions[name] = find \p .text-content

            if context is "Types"
                example = find cssify base-class
                output[context][name] = to-zen example
            else if context in ["Variations"]
                singular = find-all(cssify base-class)
                plural = find-all cssify (base-class + "s")
                examples = singular ++ plural
                output[context][name] = map minus-base-class, examples .filter (Boolean)

    each process, root.children
    output.Definitions = Definitions
    return output

    function minus-base-class el
        base-classes = base-class.split " "
        base-classes ++= base-classes.map (+ "s")
        el.class-name.split " " .filter (not in base-classes) .join " "
