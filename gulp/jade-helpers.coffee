# Jade helpers - functions and constants you can use in Jade templates
module.exports =
  pluralize: (name) ->
    if name[-1...] is 'y'
      name[...-1] + 'ies'
    else name + 's'
  join: (components...) ->
    components.join ''
  mkName: (components...) ->
    toJoin = for component, index in components
      unless component
        ''
      else if index
        component[0...1].toUpperCase() + component[1..]
      else
        component
    toJoin.join ''
  mkPath: (components...) ->
    components.join '.'
