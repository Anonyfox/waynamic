'use strict';
var App;

App = angular.module('app', ['ngCookies', 'ngResource', 'ngRoute', 'app.controllers', 'app.directives', 'app.filters', 'app.services', 'partials']);

App.config([
  '$routeProvider', '$locationProvider', function($routeProvider, $locationProvider, config) {
    $routeProvider.when('/', {
      templateUrl: '/partials/landingpage.html'
    }).when('/pictures', {
      templateUrl: '/partials/pictures.html'
    }).otherwise({
      redirectTo: '/'
    });
    return $locationProvider.html5Mode(false);
  }
]);
;'use strict';
/* Controllers*/

angular.module('app.controllers', []).controller('AppCtrl', [
  '$scope', '$location', '$resource', '$rootScope', function($scope, $location, $resource, $rootScope) {
    $scope.$location = $location;
    $scope.$watch('$location.path()', function(path) {
      return $scope.activeNavId = path || '/';
    });
    return $scope.getClass = function(id) {
      if ($scope.activeNavId.substring(0, id.length) === id) {
        return 'active';
      } else {
        return '';
      }
    };
  }
]).controller('PicturesCtrl', [
  '$scope', 'Pictures', function($scope, Pictures) {
    $scope.currentPictures = Pictures.getInitialPics(function(error, result) {
      if (error) {
        return alert(error);
      } else {
        return $scope.currentPictures = _.union(result.data.recommendations, result.data.trainingset);
      }
    });
    $scope.requestPictures = function(keywords) {
      return Pictures.getForKeywords(keywords, function(error, result) {
        if (error) {
          return alert(error);
        } else {
          console.log(result.data);
          return $scope.currentPictures = result.data;
        }
      });
    };
    $scope.nextPicturesByUrl = function(sourceUrl) {
      var pic;
      pic = _.filter($scope.currentPictures, function(p) {
        return p.url === sourceUrl;
      })[0];
      return $scope.requestPictures((pic != null ? pic.tags : void 0) || []);
    };
    return $scope.nextPicturesByTag = function(tag) {
      alert(tag);
      return $scope.requestPictures([tag]);
    };
  }
]);
;'use strict';
/* Directives*/

angular.module('app.directives', ['app.services']).directive('appVersion', [
  'version', function(version) {
    return function(scope, elm, attrs) {
      return elm.text(version);
    };
  }
]);
;'use strict';
/* Filters*/

angular.module('app.filters', []).filter('interpolate', [
  'version', function(version) {
    return function(text) {
      return String(text).replace(/\%VERSION\%/mg, version);
    };
  }
]);
;'use strict';
/* Sevices*/

angular.module('app.services', []).service("User", [
  "$http", function($http) {
    var user;
    user = {
      name: null,
      loggedIn: false
    };
    return {
      currentUser: function() {
        return user;
      },
      login: function(id, fn) {
        return $http.post("/login", {
          id: id
        }).then(function(data) {
          return typeof fn === "function" ? fn(null, data) : void 0;
        }, function(data) {
          return typeof fn === "function" ? fn({
            error: data.error || "Node ID invalid!"
          }, null) : void 0;
        });
      },
      logout: function() {
        return $http.post("/logout").then(function(result) {
          return user = {
            name: null,
            loggedIn: false
          };
        }, function(result) {
          return user = {
            name: null,
            loggedIn: false
          };
        });
      },
      checkSession: function() {
        return $http.get("/loggedin").then(function(result) {
          user.name = result.data.name;
          return user.loggedIn = true;
        }, function(fail) {});
      }
    };
  }
]).service("Pictures", [
  "$http", function($http) {
    return {
      getForKeywords: function(ary, fn) {
        return $http.get("/pictures?keywords=" + (ary.join(','))).then(function(data) {
          return typeof fn === "function" ? fn(null, data) : void 0;
        }, function(data) {
          return typeof fn === "function" ? fn({
            error: "Something went wrong. Flickr unavailable?"
          }, null) : void 0;
        });
      },
      getInitialPics: function(fn) {
        return $http.get("/users/203468/pictures").then(function(data) {
          return typeof fn === "function" ? fn(null, data) : void 0;
        }, function(data) {
          return typeof fn === "function" ? fn({
            error: "Something went wrong. Flickr unavailable?"
          }, null) : void 0;
        });
      }
    };
  }
]);
;
//# sourceMappingURL=app.js.map