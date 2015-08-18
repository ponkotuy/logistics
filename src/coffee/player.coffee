
count = 0

class @Player
  constructor: (@color, @isMine) ->
    @id = count++

  @Neutral = new Player('gray', false)
