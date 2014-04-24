'use strict'

### Controllers ###

angular.module('app.controllers', [])

.controller('AppCtrl', [
  '$scope'
  '$location'
  '$resource'
  '$rootScope'

($scope, $location, $resource, $rootScope) ->

  # Uses the url to determine if the selected
  # menu item should have the class active.
  $scope.$location = $location
  $scope.$watch('$location.path()', (path) ->
    $scope.activeNavId = path || '/'
  )

  # getClass compares the current url with the id.
  # If the current url starts with the id it returns 'active'
  # otherwise it will return '' an empty string. E.g.
  #
  #   # current url = '/products/1'
  #   getClass('/products') # returns 'active'
  #   getClass('/orders') # returns ''
  #
  $scope.getClass = (id) ->
    if $scope.activeNavId.substring(0, id.length) == id
      return 'active'
    else
      return ''
])

.controller('DashboardCtrl', ['$scope', 'Pictures', ($scope, Pictures) ->
  $scope.currentKeywords = ["Sonne","Strand","Meer","baden"]
  $scope.currentPictures = []
  $scope.requestPictures = -> Pictures.getForKeywords $scope.currentKeywords, (error, result) -> 
    if error 
      alert error 
    else 
      console.log "new pictures: ", result
      $scope.currentPictures = result
  $scope.nextPictures = (sourceUrl) ->
    pic = _.filter($scope.currentPictures, (p) -> p.url is sourceUrl)[0]
    $scope.currentKeywords = pic?.tags or $scope.currentKeywords
    $scope.requestPictures()
])
