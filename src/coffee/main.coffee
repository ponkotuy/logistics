
@init = ->
  board = new Board()

nearlyCities = (cities, x, y) ->
  targets = _.filter cities, (c) -> c.diff(x, y) <= 15
  result = _.min targets, (c) -> c.diff(x, y)
  if _.isNumber(result) then null else result # targetsが空だとInfinityが返ってくるので

logElem = $('#log')
log = (mes) ->
  text = logElem.val() + '\n' + mes
  logElem.val(text)

class @Board
  constructor: ->
    @mode = new Mode('line')
    @stage = new createjs.Stage('logistics')
    @cities = createMap(1)
    @lines = []
    @money = new Money('money', 100)
    @selected = null
    @setMouseEvent()
    @population = window.setInterval(@refresh, 1000)

  setMouseEvent: ->
    @stage.on 'stagemousedown', (m) =>
      @selected = nearlyCities(@cities, m.stageX, m.stageY)
      if @selected?
        @selected.select(true)
        @refreshView()
    @stage.on 'stagemouseup', (m) =>
      to = nearlyCities(@cities, m.stageX, m.stageY)
      if @selected?
        @selected.select(false)
        @refreshView()
        if to?
          @mode.dragAndDrop()(@, @selected, to)

  refreshView: ->
    @stage.removeAllChildren()
    @lines.forEach (line) => @stage.addChild(line.shape())
    @cities.forEach (city) =>
      @stage.addChild(city.container)
    @money.refreshView()
    @stage.update()

  addLine: (line) ->
    if line.start == line.end then return
    if !line.start.camp and !line.end.camp then return
    lines = _.filter @lines, (l) ->
      !((l.start == line.start and l.end == line.end) or
        (l.start == line.end and l.end == line.start))
    lines.push(line)
    line.start.camp = true
    line.end.camp = true
    @lines = lines

  dijekstra: (city) ->
    costs = []
    temp = []
    toNumber = (city) =>
      _.findIndex(@cities, city)
    addTemp = (city, min) =>
      @lines.forEach (line) =>
        dir = if line.start == city
            toNumber(line.end)
          else if line.end == city
            toNumber(line.start)
          else
            null
        if dir?
          newLength = min + line.length
          if (not temp[dir]? and newLength < temp[dir]) or not costs[dir]?
            temp[dir] = newLength
    f = (city, min) ->
      addTemp(city, min)
      if _.isEmpty(_.compact(temp)) then return costs
      res = findMinIndex(temp)
      costs[res] = temp[res]
      temp[res] = undefined
      f(res.key, res.val)
    f(city, 0)

  refreshPopulation: ->
    @cities.forEach (city) =>
      shorts = @dijekstra(city)
      effect = 0
      for n in [0..@cities.length]
        if @cities[n]? and shorts[n]?
          effect += @cities[n].popular / shorts[n]
      rate = city.pMax * 2 - city.popular
      goal = Math.sqrt(effect) * rate / 5
      gain = if goal < city.popular then 0 else (goal - city.popular) / 10
      city.popular += gain
      city.refresh()

  refreshMoney: ->

  refresh: =>
    @refreshPopulation()
    @refreshView()

findMinIndex = (xs) ->
  min = Infinity
  index = -1
  for n in [0...xs.length]
    if xs[n]? and xs[n] < min
      index = n
      min = xs[n]
  index
