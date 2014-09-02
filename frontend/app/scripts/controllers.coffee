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
  $scope.currentPictures = Pictures.getInitialPics (error, result) ->
    if error
      alert error
    else
      $scope.currentPictures = result.data.trainingset

  $scope.requestPictures = (keywords) -> Pictures.getForKeywords keywords, (error, result) ->
    if error
      alert error
    else
      console.log result.data
      $scope.currentPictures = result.data

  $scope.nextPicturesByUrl = (sourceUrl) ->
    pic = _.filter($scope.currentPictures, (p) -> p.url is sourceUrl)[0]
    $scope.requestPictures( pic?.tags or [] )

  $scope.nextPicturesByTag = (tag) ->
    alert tag
    $scope.requestPictures( [tag] )
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
