$(document)
  .on('mouseenter', '[data-object~="hover-show"]', ->
    return false unless document.documentElement.ontouchstart == undefined
    $('[data-object~="hover-show"]').each( (index, element) ->
      $($(element).data('target')).hide()
      $($(element).data('target-default')).show()
    )
    $($(this).data('target-default')).hide()
    $($(this).data('target')).show()
  )
  .on('mouseleave', '[data-object~="hover-show"]', ->
    $($(this).data('target')).hide()
    $($(this).data('target-default')).show()
  )
