
class @Money
  constructor: (id, @money) ->
    @input = $('#' + id)

  refreshView: ->
    @input.html("<strong>#{@money.toFixed(0)}</strong>")

  payment: (pay) ->
    if @money < pay
      log('資金が不足しています')
      false
    else
      @money -= pay
      true
