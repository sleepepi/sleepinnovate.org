$(document)
  .on('click', '[data-object~="consent-with-checkbox"]', ->
    if $("#read_consent:checked").length > 0
      $("#consent-form").submit()
    else
      alert 'Please check the box if you give your consent.'
    false
  )
