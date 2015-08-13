
class @City
  constructor: (@x, @y, @area) ->
    @pMax = City.PopularMax[@area]
    @popular = @pMax / 10
    @container = @createContainer()
    @selector = null

  createContainer: () ->
    c = new createjs.Container()
    c.x = @x
    c.y = @y
    c.addChild(@circle())
    c.addChild(@popularText())
    c

  circle: ->
    s = new createjs.Shape()
    s.graphics.beginFill('red').drawCircle(0, 0, City.Sizes[@area])
    s

  popularText: ->
    new createjs.Text(@popular, '20px Arial', 'black')

  diff: (x, y) ->
    diff(@x, @y, x, y)

  select: (flag) ->
    if flag
      @selector = new createjs.Shape()
      @selector.graphics.beginStroke('black').drawCircle(0, 0, 15)
      @container.addChild(@selector)
    else
      @container.removeChild(@selector)

  @Sizes: [0, 4, 4, 5, 5, 6]

  @PopularMax: [0, 10, 20, 30, 50, 100]

diff = (x1, y1, x2, y2) ->
  x = x1 - x2
  y = y1 - y2
  Math.sqrt(x*x + y*y)
