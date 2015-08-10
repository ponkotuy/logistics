
@init = ->
  new Board()

nearlyCities = (cities, x, y) ->
  targets = _.filter cities, (c) -> c.diff(x, y) <= 15
  result = _.min targets, (c) -> c.diff(x, y)
  if _.isNumber(result) then null else result # targetsが空だとInfinityが返ってくるので

logElem = $('#log')
log = (mes) ->
  text = logElem.val() + '\n' + mes
  logElem.val(text)

class Board
  constructor: ->
    @mode = new Mode('line')
    @stage = new createjs.Stage('logistics')
    @cities = [
      new City(100, 100, 5),
      new City(50, 100, 3),
      new City(150, 50, 3)
    ]
    @lines = [new Line(@cities[0], @cities[1])]
    @setMouseEvent()
    @refreshView()
    @selected = null
    @stage.update()

  setMouseEvent: ->
    @stage.on 'stagemousedown', (m) =>
      @selected = nearlyCities(@cities, m.stageX, m.stageY)
      if @selected?
        @selected.select(true)
        @stage.update()
    @stage.on 'stagemouseup', (m) =>
      to = nearlyCities(@cities, m.stageX, m.stageY)
      if @selected?
        @selected.select(false)
        if to?
          line = new Line(@selected, to)
          @lines.push(line)
          @refreshView()
        @stage.update()

  refreshView: ->
    @stage.clear()
    @lines.forEach (line) => @stage.addChild(line.shape())
    @cities.forEach (city) =>
      @stage.addChild(city.container)
