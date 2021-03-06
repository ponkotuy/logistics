
class @Line
  constructor: (@start, @end) ->
    @scale = 1
    @length = @start.diff(@end.x, @end.y)

  shape: ->
    s = new createjs.Shape()
    s.graphics.setStrokeStyle(@scale)
    s.graphics.beginStroke('black')
    s.graphics.moveTo(@start.x, @start.y)
    s.graphics.lineTo(@end.x, @end.y)
    s.graphics.endStroke()
    s

  buildCost: ->
    @length

  upgradeCost: ->
    @length * (@scale + 1)

  upgrade: ->
    @scale += 1

  transitCost: ->
    @length / @scale
