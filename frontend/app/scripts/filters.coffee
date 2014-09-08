'use strict'

### Filters ###

angular.module('app.filters', [])

.filter('interpolate', ['version', (version) ->
  (text) ->
    String(text).replace(/\%VERSION\%/mg, version)
])

.filter('shortText', [->
  (str) -> str[0...30]
])