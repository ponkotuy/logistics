
class SeedRandom
  constructor: (@seed) ->

  float: ->
    x = Math.sin(@seed++) * 10000
    x - Math.floor(x)

  # 正の整数
  int: (n) ->
    Math.floor(@float() * n)

class Random
  constructor: () ->

  # 正の整数
  int: (n) ->
    Math.floor(Math.random() * n)

Players = [
  new Player('red', true),
  new Player('green', false),
  new Player('yellow', false),
  new Player('blue', false)
]

CitySize =
  small: [1, 1, 2, 2, 2, 3, 3, 4]
  normal: [1, 2, 3, 4]
  large: [1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5]

readSettings = ->
  map = getCheckVal('map')
  ais = parseint(getCheckVal('ais'))
  density = getCheckVal('density')
  citySize = getCheckVal('city-size')
  {seed: null, players: _.slice(Players, 0, ais + 1), citySize: CitySize[citySize], size: }

getCheckVal = (name) ->
  $("""input[name="#{name}"]:checked""").val()


# size = {x: hoge, y: fuga}
@createMap = (seed, players, size) ->
  random = if seed? then new SeedRandom(seed) else new Random()
  missCount = 0
  cities = createPlayerCities(players, size)
  while missCount < 100
    x = random.int(size.x - 40) + 20
    y = random.int(size.y - 40) + 20
    city = new City(x, y, random.int(4) + 1)
    if _.all(50 <= c.diff(x, y) for c in cities)
      cities.push(city)
    else
      missCount++
  cities

createPlayerCities = (players, size) ->
  switch players.length
    when 1 then [new City(size.x / 2, size.y / 2, 5, players[0])]
    when 2
      eighth = {x: size.x/8, y: size.y/8}
      [
        new City(eighth.x, eighth.y, 5, players[0]),
        new City(size.x - eighth.x, size.y - eighth.y, 5, players[1])
      ]
    when 3
      eighth = {x: size.x/8, y: size.y/8}
      [
        new City(eighth.x, eighth.y, 5, players[0]),
        new City(size.x - eighth.x, eighth.y, 5, players[1]),
        new City(size.x / 2, size.y - eighth.y, 5, players[2])
      ]
    when 4
      eighth = {x: size.x/8, y: size.y/8}
      [
        new City(eighth.x, eighth.y, 5, players[0]),
        new City(size.x - eighth.x, eighth.y, 5, players[1]),
        new City(eighth.x, size.y - eighth.y, 5, players[2]),
        new City(size.x - eighth.x, size.y - eighth.y, 5, players[3])
      ]
    else
      []
