
board = null

@init = ->
  $('#start_btn').click -> $('#tab a[href="#board"]').tab('show')
  $('#tab a[href="#board"]').on 'show.bs.tab', -> start()
  $('#tab a[href="#board"]').on 'hide.bs.tab', ->
    board.clear()
    logClear()

start = ->
  settings = readSettings()
  $('#logistics').attr('width', settings.size.x)
  $('#logistics').attr('height', settings.size.y)
  board = new Board(settings)

nearlyCities = (cities, x, y) ->
  targets = _.filter cities, (c) -> c.diff(x, y) <= 15
  result = _.min targets, (c) -> c.diff(x, y)
  if _.isNumber(result) then null else result # targetsが空だとInfinityが返ってくるので

class @Board
  constructor: (settings) ->
    @stage = new createjs.Stage('logistics')
    @players = settings.players
    @ais = _.rest(@players).map (color) -> new AI(new Money('', 100), color)
    @cities = createMap(null, settings)
    @lines = []
    @money = new Money('money', 100)
    @selected = null
    @setMouseEvent()
    @refreshEvent = window.setInterval(@refresh, 1000)

  clear: ->
    window.clearInterval(@refreshEvent)

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
    @cities.forEach (city) => @stage.addChild(city.container)
    @money.refreshView()
    @stage.update()

  addLine: (line) ->
    if line.start == line.end
      log('始点と終点が同じです')
      return
    if !line.start.camp.isMine and !line.end.camp.isMine
      log('味方の都市が含まれていません')
      return
    dup = (_.filter @lines, (l) ->
      ((l.start == line.start and l.end == line.end) or
        (l.start == line.end and l.end == line.start)))[0]
    if dup?
      if @money.payment(line.upgradeCost())
        dup.upgrade()
    else
      if @money.payment(line.buildCost())
        @lines.push(line)

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
          newCost = min + line.transitCost()
          if (not temp[dir]? and newCost < temp[dir]) or not costs[dir]?
            temp[dir] = newCost
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
        @lines = _.filter @lines, (line) ->
          if line.start == city
            console.log(line.end.camp, newCamp)
            line.end.camp.id == newCamp
          else if line.end == city
            console.log(line.start.camp, newCamp)
            line.start.camp.id == newCamp
          else
            true
        city.camp = _.find @players, (p) -> p.id == newCamp
      city.refresh()

  refreshMoney: ->
    homes = _.filter @cities, (city) -> city.camp.isMine
    p = _.sum homes, (c) -> c.popular
    @money.money += p / 10

  refreshAI: ->
    @ais.forEach (ai) =>
      action = ai.run(@cities, @lines)
      if action?
        AIAction[action.type](@, ai, action)
    @ais.forEach (ai) => ai.refreshMoney(@cities)

  refresh: =>
    @refreshPopulation()
    @refreshMoney()
    @refreshView()
    @refreshAI()

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

AIAction =
  createLine: (board, ai, obj) ->
    if ai.money.payment(obj.line.buildCost())
      board.lines.push(obj.line)
  upgradeLine: (board, ai, obj) ->
    if ai.money.payment(obj.line.upgradeCost())
      obj.line.upgrade()
