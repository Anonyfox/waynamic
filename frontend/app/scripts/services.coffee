'use strict'

### Sevices ###

angular.module('app.services', [])

.service("User", ["$http", ($http) ->
  users = {
    list: []
    current: {_id: 0, name: ""}
  }
  return {
    users: -> users
    currentUser: -> users.current
    currentUserId: -> users.current._id
    setCurrentUser: (u) -> users.current = u
    getAllUsers: (fn) ->
      $http.get("/users").then(
        (data) ->
          users.list = _.map data.data, (u) -> {_id: u._id, name: "##{u._id} #{u.firstName} #{u.lastName}"}
          fn? null, users.list
        (data) -> fn? null, []
      )
    # login: (id, fn) ->
    #   $http.post("/login", {id: id}).then(
    #     (data) -> fn? null, data
    #     (data) -> fn? {error: (data.error or "Node ID invalid!")}, null
    #   )
    # logout: ->
    #   $http.post("/logout").then(
    #     (result) -> user = {name: null, loggedIn: false}
    #     (result) -> user = {name: null, loggedIn: false} # force logout anyway :P
    #   )
    # checkSession: ->
    #   $http.get("/loggedin").then(
    #     (result) ->
    #       user.name = result.data.name
    #       user.loggedIn = true
    #     (fail) ->
    #   )

  }
])

.service("Pictures", ["$http", "User", ($http, User) ->
  getPicsByFeedback: (postBody, fn) ->
    $http.post("/users/#{User.currentUserId()}/pictures", postBody).then(
      (data) -> fn? null, data
      (data) -> fn? {error: "Something went wrong. Flickr unavailable?"}, null
    )
  getInitialPics: (fn) ->
    $http.get("/users/#{User.currentUserId()}/pictures").then(
      (data) -> fn? null, data
      (data) -> fn? {error: "Something went wrong. Flickr unavailable?"}, null
    )
])
