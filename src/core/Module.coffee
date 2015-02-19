moduleKeywords = ['included', 'extended']

class Module
  @include: (obj) ->
    throw('include(obj) requires obj') unless obj
    for key, value of obj.prototype when key not in moduleKeywords
      @::[key] = value

    included = obj.included
    included.apply(this) if included
    @

    
module.exports = Module
