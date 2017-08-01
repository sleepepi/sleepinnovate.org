@masksReady = ->
  $.each($("[data-mask]"), ->
    $(this).mask($(this).data('mask'))
  )
