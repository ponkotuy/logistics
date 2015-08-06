@init = ->
  mode = new Mode('line')
  stage = new createjs.Stage('logistics')
  cities = [
    new City(100, 100, 5),
    new City(50, 100, 3),
    new City(150, 50, 3)
  ]
  lines = [new Line(cities[0], cities[1])]
  lines.forEach (line) -> stage.addChild(line.shape())
  cities.forEach (city) -> stage.addChild(city.shape())
  stage.update()

class City
  constructor: (@x, @y, @area) ->
    @popular = 0

  shape: () ->
    s = new createjs.Shape()
    s.x = @x
    s.y = @y
    s.graphics.beginFill('red').drawCircle(0, 0, @Sizes[@area])
    s

  Sizes: [0, 4, 4, 5, 5, 6]

class Line
  constructor: (@start, @end) ->
    @scale = 1

  shape: () ->
    s = new createjs.Shape()
    s.graphics.setStrokeStyle(2)
    s.graphics.beginStroke('black')
    s.graphics.moveTo(@start.x, @start.y)
    s.graphics.lineTo(@end.x, @end.y)
    s.graphics.endStroke()
    s

class Mode
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
