
class @Money
  constructor: (id, @money) ->
    @input = $('#' + id)

  refreshView: ->
    @input.html("<strong>#{@money.toFixed(0)}</strong>")
