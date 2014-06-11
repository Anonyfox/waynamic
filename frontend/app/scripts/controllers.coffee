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
  }, {
     "url": "http://farm3.staticflickr.com/2914/14355218095_6e23e19d27.jpg",
     "title": "Northern values",
     "tags": [
       "ricohgr",
       "urbanfragments",
       "vsco",
       "chipshop",
       "cafe"
     ]}]
   # }, {
   #   "url": "http://farm3.staticflickr.com/2916/14347705831_86eb0ac93e.jpg",
   #   "title": "Livistona victoriae- Victoria River fan palm",
   #   "tags": [
   #     "australia",
   #     "cliff",
   #     "escarpment",
   #     "fanpalm",
   #     "gregorynationalpark",
   #     "livistona",
   #     "livistonavictoriae",
   #     "nawulbinbinwalk",
   #     "northernterritory",
   #     "victoriariverfanpalm"
   #   ]
   # }, {
   #   "url": "http://farm3.staticflickr.com/2930/14168351167_b3c86ba8a5.jpg",
   #   "title": "In shadow",
   #   "tags": [
   #     "nikond800",
   #     "nikonafsnikkor1635mm14gedvr",
   #     "tree",
   #     "auchinedenhill",
   #     "queensview",
   #     "sunset",
   #     "sunlight",
   #     "sunrays",
   #     "shadows",
   #     "scotland",
   #     "warmlight",
   #     "shadow"
   #   ]
   # }, {
   #   "url": "http://farm4.staticflickr.com/3835/14352187354_2dd3c5bea7.jpg",
   #   "title": "Fhotographs",
   #   "tags": [
   #     "juanjofotos",
   #     "juanjosales",
   #     "nikond300",
   #     "adamski",
   #     "people",
   #     "explore"
   #   ]
   # }, {
   #   "url": "http://farm3.staticflickr.com/2928/14167441168_b50320a593.jpg",
   #   "title": "1965 Porsche 911 - David Amar / Pietro Vergnano",
   #   "tags": [
   #     "2014",
   #     "24th",
   #     "brandshatch",
   #     "car",
   #     "cars",
   #     "d90",
   #     "f1",
   #     "festival",
   #     "masters",
   #     "may",
   #     "michaelturnerphotography",
   #     "motorracing",
   #     "nikon",
   #     "nikond90",
   #     "racing",
   #     "sport",
   #     "summer",
   #     "rain",
   #     "track",
   #     "wet"
   #   ]
   # }, {
   #   "url": "http://farm4.staticflickr.com/3877/14353112655_4397810f60.jpg",
   #   "title": "Last Checks.",
   #   "tags": [
   #     "paratroopers",
   #     "douglasdc3",
   #     "leeonsolent",
   #     "unionjackdak",
   #     "dakota",
   #     "224064",
   #     "n74589",
   #     "dday",
   #     "usaf",
   #     "uk",
   #     "england",
   #     "70thanniversaryofdday"
   #   ]
   # }, {
   #   "url": "http://farm4.staticflickr.com/3911/14350448824_425deac8c5.jpg",
   #   "title": "Gunung Bromo",
   #   "tags": [
   #     "cemorolawang",
   #     "mountbromo",
   #     "gunungbromo",
   #     "java",
   #     "eastjava",
   #     "indonesia"
   #   ]
   # }]
  # Pictures.getInitialPics (error, result) ->
  #   console.log "error: ", error
  #   console.log "result: ", result
  #   if error then console.log error else $scope.currentPictures = result.data

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

# .controller('LoginCtrl', ['$scope', 'User', ($scope, User) ->
#   $scope.loginNewUser = ->
#     userId = $scope.newUser.nodeId
#     User.login (error, user) ->
#       if error
#         console.log "LoginError! ", error
#       else
#         console.log "Logged IN! ", user
# ])