
class @City
  constructor: (@x, @y, @area, @camp) ->
    @pMax = City.PopularMax[@area]
    @popular = @pMax / 10
    @selected = false
    @camp ?= Player.Neutral
    @refresh()

  createContainer: () ->
    c = new createjs.Container()
    c.x = @x
    c.y = @y
    c.addChild(@circle())
    c.addChild(@popularText())
    c.addChild(@createSelector())
    c

  circle: ->
    s = new createjs.Shape()
    color = @camp.color
    s.graphics.beginFill(color).drawCircle(0, 0, City.Sizes[@area])
    s

  popularText: ->
    new createjs.Text(@popular.toFixed(0), '18px Arial', 'black')

  diff: (x, y) ->
    diff(@x, @y, x, y)

  createSelector: () ->
    if @selected
      s = new createjs.Shape()
      s.graphics.beginStroke('black').drawCircle(0, 0, 15)
      s
    else
      null

  select: (flag) ->
    @selected = flag
    @refresh()

  refresh: () ->
    @container = @createContainer()

  @Sizes: [0, 4, 4, 5, 5, 6]

  @PopularMax: [0, 20, 30, 40, 50, 100]

diff = (x1, y1, x2, y2) ->
  x = x1 - x2
  y = y1 - y2
  Math.sqrt(x*x + y*y)
