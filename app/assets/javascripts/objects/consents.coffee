$(document)
  .on("click", "[data-object~=consent-with-checkbox]", ->
    if $("#read_consent:checked").length > 0
      $("#consent-form").submit()
    else
      $(".consent-checkbox").addClass("bg-success text-white")
      alert "Please check the box if you give your consent."
    false
  )
