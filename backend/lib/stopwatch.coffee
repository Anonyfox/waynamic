Stopwatch = exports? and exports or @Stopwatch = {}

times = {}

Stopwatch.start = (name) ->
  times[name] = new Date()

Stopwatch.stop = (name) ->
  return console.log " ◷ ERROR: no '#{name}' registered" unless times[name]
  console.info " ◷ FINISHED #{name} after %dms", new Date() - times[name]

