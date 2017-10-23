@sessionsReady = ->
  if $('[data-object~="start-new-session"]').length > 0
    interval = setTimeout(sessionTimedOut, 1000 * 60 * 3) # Once every 3 minutes ((1000 ms * 60) * 3)

@sessionTimedOut = ->
  if $('[data-object~="start-new-session"]').length > 0
    window.location = $('[data-object~="start-new-session"]').attr("href")
