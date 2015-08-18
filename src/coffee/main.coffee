
@init = ->
  board = new Board()

nearlyCities = (cities, x, y) ->
  targets = _.filter cities, (c) -> c.diff(x, y) <= 15
  result = _.min targets, (c) -> c.diff(x, y)
  if _.isNumber(result) then null else result # targetsが空だとInfinityが返ってくるので

log = (mes) ->
  before = $('#log').val()
  text = (if before then before + '\n' else '') + mes
  $('#log').val(text)
  console.log(mes)

class @Board
  constructor: ->
    @stage = new createjs.Stage('logistics')
    @players = [new Player('red', true)]
    @cities = createMap(Math.random(), @players)
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
        if to? then @addLine(new Line(@selected, to))
        @refreshView()

  refreshView: ->
    @stage.removeAllChildren()
    @lines.forEach (line) => @stage.addChild(line.shape())
    @cities.forEach (city) =>
      @stage.addChild(city.container)
    @money.refreshView()
    @stage.update()

  addLine: (line) ->
    if line.start == line.end
      log('始点と終点が同じです')
      return
    if !line.start.camp.isMine and !line.end.camp.isMine
      log('味方の都市が含まれていません')
      return
    if @money.money < line.buildCost()
      log('資金が不足しています')
      return

    lines = _.filter @lines, (l) ->
      !((l.start == line.start and l.end == line.end) or
        (l.start == line.end and l.end == line.start))
    lines.push(line)
    @money.money -= line.buildCost()
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
      effects = [0]
      for n in [0..@cities.length]
        if @cities[n]? and shorts[n]?
          if @cities[n].camp == Player.Neutral then continue
          x = @cities[n].popular / shorts[n]
          effects[@cities[n].camp.id] ?= 0
          effects[@cities[n].camp.id] += x
      effects[city.camp.id] ?= 0
      effects[city.camp.id] += 0.0625
      effect = _.sum((if city.camp.id == i then e else -e) for e, i in effects)
      rate = city.pMax * 2.1 - city.popular
      goal = Math.sign(effect) * Math.sqrt(Math.abs(effect)) * rate / 5
      gain = (goal - city.popular) / 10
      city.popular += gain
      if city.popular < 1
        city.popular = 1
        effects[Player.Neutral.id] = 0
        newCamp = maxIndex(effects)
        city.camp = _.find @players, (p) -> p.id == newCamp
      city.refresh()

  refreshMoney: ->
    homes = _.filter @cities, (city) -> city.camp.isMine
    p = _.sum homes, (c) -> c.popular
    @money.money += p / 10

  refresh: =>
    @refreshPopulation()
    @refreshMoney()
    @refreshView()

findMinIndex = (xs) ->
  min = Infinity
  index = -1
  for n in [0...xs.length]
    if xs[n]? and xs[n] < min
      index = n
      min = xs[n]
  index

maxIndex = (xs) ->
  idx = -1
  val = -Infinity
  xs.forEach (x, i) ->
    if val < x
      idx = i
      val = x
  idx
