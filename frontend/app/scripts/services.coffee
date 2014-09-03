'use strict'

### Sevices ###

angular.module('app.services', [])

.service("User", ["$http", ($http) ->
  user = {name: null, loggedIn: false}
  return {
    currentUser: -> user
    login: (id, fn) ->
      $http.post("/login", {id: id}).then(
        (data) -> fn? null, data
        (data) -> fn? {error: (data.error or "Node ID invalid!")}, null
      )
    logout: ->
      $http.post("/logout").then(
        (result) -> user = {name: null, loggedIn: false}
        (result) -> user = {name: null, loggedIn: false} # force logout anyway :P
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
  getPicsByFeedback: (postBody, fn) ->
    $http.post("/users/203468/pictures", postBody).then(
      (data) -> fn? null, data
      (data) -> fn? {error: "Something went wrong. Flickr unavailable?"}, null
    )
  getInitialPics: (fn) ->
    $http.get("/users/203468/pictures").then(
      (data) -> fn? null, data
      (data) -> fn? {error: "Something went wrong. Flickr unavailable?"}, null
    )
])
