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
    tags: ["Sonne","Strand","Meer"]
    title: "tramonto in Grecia (Loutraki - golfo di Corinto)"
    url: "http://farm8.staticflickr.com/7295/13972537026_913a8a116b.jpg"
  }, {
    title: "Lac de Capitello, een paternostermeer, Corsica Frankrijk 2002"
    url: "http://farm6.staticflickr.com/5218/13981158706_c497a0feff.jpg"
    tags: ["lacdecapitello","paternostermeer","meer","lake","lac","corsica","corse","frankrijk","france","2002"]
  } ]

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
    $scope.requestPictures( [tag] )
])
