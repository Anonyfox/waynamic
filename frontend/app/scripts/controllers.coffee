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

.controller('PicturesCtrl', ['$scope', 'Pictures', ($scope, Pictures) ->

  $scope.Current = Pictures.getInitialPics (error, result) ->
    return  error if error
    $scope.Current = result.data

  $scope.feedback = (_id) ->
    postBody = _.extend $scope.Current, clicked:_id
    Pictures.getPicsByFeedback postBody, (error, result) ->
      return  error if error
      $scope.Current = result.data
])

# .controller('LoginCtrl', ['$scope', 'User', ($scope, User) ->
#   $scope.loginNewUser = ->
#     userId = $scope.newUser.nodeId
#     User.login (error, user) ->
#       if error
#         console.log "LoginError! ", error
#       else
#         console.log "Logged IN! ", user
# ])
