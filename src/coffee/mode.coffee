
modes =
  line:
    dragAndDrop: (board, from, to) ->
      board.addLine(new Line(from, to))
      board.refreshView()
  army:
    dragAndDrop: (board, from, to) -> null

class @Mode
  Selects: Object.keys(modes)

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

  dragAndDrop: ->
    modes[@select].dragAndDrop
