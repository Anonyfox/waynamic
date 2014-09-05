'use strict'

### Sevices ###

angular.module('app.services', [])

.service("User", ["$http", "$rootScope", ($http, $rootScope) ->
  $rootScope.users = {
    list: []
    current: {_id: 0, name: ""}
  }
  return {
    users: -> $rootScope.users
    currentUser: -> $rootScope.users.current
    currentUserId: -> $rootScope.users.current._id
    setCurrentUser: (u) -> $rootScope.users.current = u
    getAllUsers: (fn) ->
      $http.get("/users").then(
        (data) ->
          $rootScope.users.list = _.map data.data, (u) -> {_id: u._id, name: "##{u._id} #{u.firstName} #{u.lastName}"}
          fn? null, $rootScope.users.list
        (data) -> fn? null, []
      )
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
