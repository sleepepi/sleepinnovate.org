$(document)
  .on('click', '[data-object~="consent-with-checkbox"]', ->
    if $("#read_consent:checked").length > 0
      $("#consent-form").submit()
    else
      alert 'Please mark that you give your consent.'
    false
  )
