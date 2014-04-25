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
  $scope.currentPictures = [{
    tags: ["Sonne","Strand","Meer","baden"]
    title: "tramonto in Grecia (Loutraki - golfo di Corinto)"
    url: "http://farm8.staticflickr.com/7295/13972537026_913a8a116b.jpg"
  } ]

  $scope.requestPictures = (keywords) -> Pictures.getForKeywords keywords, (error, result) -> 
    if error 
      alert error
    else
      $scope.currentPictures = result.data

  $scope.nextPicturesByUrl = (sourceUrl) ->
    pic = _.filter($scope.currentPictures, (p) -> p.url is sourceUrl)[0]
    $scope.requestPictures( pic?.tags or [] )

  $scope.nextPicturesByTag = (tag) ->
    $scope.requestPictures( [tag] )
])
