
class Random
  constructor: (@seed) ->

  float: ->
    x = Math.sin(@seed++) * 10000
    x - Math.floor(x)

  int: (n) -> # 正の数に限る
    Math.floor(@float() * n)

@createMap = (seed) ->
  random = new Random(seed)
  missCount = 0
  cities = [new City(320, 240, 5)]
  while missCount < 100
    city = new City(random.int(600) + 20, random.int(440) + 20, random.int(4) + 1)
    x = city.x
    y = city.y
    if _.all(60 <= c.diff(x, y) for c in cities)
      cities.push(city)
    else
      missCount++
  cities
