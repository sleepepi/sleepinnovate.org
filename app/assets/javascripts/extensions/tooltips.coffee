@tooltipsReady = ->
  $('.tooltip').remove()
  return unless document.documentElement.ontouchstart == undefined
  $('[data-toggle="tooltip"]').tooltip()
