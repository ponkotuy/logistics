
class @Money
  constructor: (id, @money) ->
    @input = $('#' + id)

  refreshView: ->
    @input.val(@money)
