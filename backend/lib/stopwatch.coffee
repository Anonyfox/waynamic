Stopwatch = exports? and exports or @Stopwatch = {}

times = {}

Stopwatch.start = (name) ->
  times[name] = new Date()
  console.info " ◷ START #{name}"

Stopwatch.stop = (name) ->
  return console.log " ◷ ERROR: no '#{name}' registered" unless times[name]
  console.info " ◷ FINISHED #{name} in %dms", new Date() - times[name]

