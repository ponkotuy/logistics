
class @Line
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
