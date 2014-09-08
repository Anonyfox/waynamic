'use strict'

### Controllers ###

angular.module('app.controllers', [])

.controller('AppCtrl', [
  '$scope'
  '$location'
  '$resource'
  '$rootScope'

($scope, $location, $resource, $rootScope) ->
  $scope.$location = $location
  $scope.$watch('$location.path()', (path) -> $scope.activeNavId = path || '/')
  $scope.getClass = (id) -> if $scope.activeNavId.substring(0, id.length) == id then 'active' else ''
])

.controller('NavCtrl', ['$scope', 'User', ($scope, User) ->
  $scope.changeSelectedUser = (u) ->
    User.setCurrentUser u
  User.getAllUsers()
])

.controller('ProfileCtrl', ['$scope', 'User', ($scope, User) ->
  User.getUserProfile()

  # Re-render start screen on user change
  $scope.$watch "users.current._id", (oldValue, newValue) ->
    if oldValue isnt newValue
      User.getUserProfile()

  $scope.switchUserTo = (id) ->
    User.setCurrentUserById id
])

.controller('PicturesCtrl', ['$scope', '$rootScope', 'Pictures', 'User', ($scope, $rootScope, Pictures, User) ->
  # Start Screen
  Pictures.getInitialPics()

  # Re-render start screen on user change
  $scope.$watch "users.current._id", (oldValue, newValue) ->
    if oldValue isnt newValue
      Pictures.getInitialPics()

  # render new screen with updated feedback on user click event
  $scope.feedback = (_id) ->
    $("#pictures-view").hide()
    postBody = _.extend $rootScope.Current, clicked:_id
    Pictures.getPicsByFeedback postBody, (error, result) ->
      $("#pictures-view").fadeIn()
])