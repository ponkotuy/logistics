
linesFromCity = (city, lines) ->
  _.filter lines, (l) ->
    l.start == city or l.end == city

citiesFromCity = (city, lines) ->
  xs = lines.map (l) ->
    if l.start == city then [l.end]
    else if l.end == city then [l.start]
    else []
  _.flatten(xs)

class @AI
  constructor: (@money, @player) ->

  run: (cities, lines) ->
    cand = [
      @createLine(cities, lines),
      @upgradeLine(cities, lines)]
    filtered = _.filter cand, (c) => c.cost <= @money.money
    result = _.min filtered, (c) -> c.cost
    if _.isNumber(result) then null else result

  createLine: (cities, lines) ->
    xs = _.groupBy cities, (c) => c.camp == @player
    mine = xs['true']
    enemies = xs['false']
    minEnemyCities = mine.map (m) ->
      joined = citiesFromCity(m, lines)
      unJoined = _.reject enemies, (e) -> _.includes(joined, e)
      minEnemyCity = _.min unJoined, (e) -> m.diff(e.x, e.y)
      [m, minEnemyCity]
    minEnemyCity = _.min minEnemyCities, (tuple) ->
      enemy = tuple[1]
      tuple[0].diff(enemy.x, enemy.y)
    line = new Line(minEnemyCity[0], minEnemyCity[1])
    {type: 'createLine', cost: line.buildCost(), line: line}

  upgradeLine: (cities, lines) ->
    myLines = _.filter lines, (line) =>
      line.start.camp == @player and line.end.camp == @player
    line = _.max myLines, (line) ->
      line.start.popular * line.end.popular / (line.scale * line.scale)
    if _.isNumber(line)
      {type: null, cost: Infinity}
    else
      {type: 'upgradeLine', cost: line.upgradeCost(), line: line}

  refreshMoney: (cities) ->
    homes = _.filter cities, (city) => city.camp == @player
    p = _.sum homes, (city) -> city.popular
    @money.money += p / 10
