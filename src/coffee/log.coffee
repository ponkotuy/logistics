
@log = (mes) ->
  before = $('#log').val()
  text = (if before then before + '\n' else '') + mes
  $('#log').val(text)
  console.log(mes)
