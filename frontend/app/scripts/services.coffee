'use strict'

### Sevices ###

angular.module('app.services', [])

.service("User", ["$http", "$rootScope", ($http, $rootScope) ->
  $rootScope.users = {
    list: []
    current: {_id: -1, name: ""}
  }
  return {
    currentUserId: -> $rootScope.users.current._id
    setCurrentUser: (u) -> $rootScope.users.current = u
    setCurrentUserById: (id) -> $rootScope.users.current = _.find $rootScope.users.list, (u) -> u._id is id
    getAllUsers: (fn) ->
      $http.get("/users").then(
        (data) ->
          $rootScope.users.list = _.map data.data, (u) -> {_id: u._id, name: "##{u._id} #{u.firstName} #{u.lastName}"}
          fn? null, $rootScope.users.list
        (data) -> fn? null, []
      )
    getUserProfile: (fn) ->
      $http.get("/users/#{$rootScope.users.current._id}/profile").then(
        (data) ->
          $rootScope.users.current.friends = data.data.friends
          $rootScope.users.current.history = data.data.history
          fn? null, $rootScope.current
        (data) -> fn? null, {}
      )
  }
])

.service("Pictures", ["$http", "$rootScope", "User", ($http, $rootScope, User) ->
  $rootScope.Current = {
    list: []
    current: {_id: 0, url: ""}
  }
  getPicsByFeedback: (postBody, fn) ->
    $http.post("/users/#{User.currentUserId()}/pictures", postBody).then(
      (data) ->
        $rootScope.Current = data.data
        fn? null, data.data
      (data) -> fn? {error: "Something went wrong. Flickr unavailable?"}, null
    )
  getInitialPics: (fn) ->
    $http.get("/users/#{User.currentUserId()}/pictures").then(
      (data) ->
        $rootScope.Current = data.data
        fn? null, data.data
      (data) -> fn? {error: "Something went wrong. Flickr unavailable?"}, null
    )
])
