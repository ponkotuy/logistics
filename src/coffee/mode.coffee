
class @Mode
  Selects: ['line', 'army']

  constructor: (@select) ->
    @Selects.forEach (sel) =>
      $('#' + sel).click () =>
        @change(sel)

  change: (sel) ->
    @select = sel
    @Selects.forEach (s) ->
      if s == sel
        $('#' + s).addClass('active')
      else
        $('#' + s).removeClass('active')
