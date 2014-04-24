'use strict'

### Sevices ###

angular.module('app.services', [])

.service("User", ["$http", ($http) ->
  user = {name: null, loggedIn: false}
  return {
    currentUser: -> user
    login: (name, password, fn) ->
      $http.post("/login", {username: name, password: password}).then(
        (data) -> fn? null, data
        (data) -> fn? {error: (data.error or "Name or password invalid!")}, null
      )
    logout: ->
      $http.post("/logout").then(
        (result) -> user = {name: null, loggedIn: false}
        (result) -> user = {name: null, loggedIn: false} # force logout anyway :P
      )
    register: (name, password, fn) ->
      $http.post("/register", {username: name, password: password}).then(
        (data) -> fn? null, data
        (data) -> fn? {server: data.error}, null
      )
    checkSession: ->
      $http.get("/loggedin").then(
        (result) -> 
          user.name = result.data.name
          user.loggedIn = true
        (fail) -> 
      )
  }
])

.service("Pictures", ["$http", ($http) ->
  getForKeywords: (ary, fn) ->
    $http.get("/pictures?keywords=#{ary.join(',')}").then(
      (data) -> fn? null, data
      (data) -> fn? {error: "Something went wrong. Flickr unavailable?"}, null
    )
])
