'use strict';
var App;

App = angular.module('app', ['ngCookies', 'ngResource', 'ngRoute', 'app.controllers', 'app.directives', 'app.filters', 'app.services', 'partials']);

App.config([
  '$routeProvider', '$locationProvider', function($routeProvider, $locationProvider, config) {
    $routeProvider.when('/', {
      templateUrl: '/partials/landingpage.html'
    }).when('/pictures', {
      templateUrl: '/partials/pictures.html'
    }).when('/profile', {
      templateUrl: '/partials/profile.html'
    }).when('/import', {
      templateUrl: '/partials/import.html'
    }).when('/register', {
      templateUrl: '/partials/register.html'
    }).when('/login', {
      templateUrl: '/partials/login.html'
    }).when('/logout', {
      templateUrl: '/partials/logout.html'
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
    $scope.currentPictures = [
      {
        tags: ["Sonne", "Strand", "Meer", "baden"],
        title: "tramonto in Grecia (Loutraki - golfo di Corinto)",
        url: "http://farm8.staticflickr.com/7295/13972537026_913a8a116b.jpg"
      }
    ];
    $scope.requestPictures = function(keywords) {
      return Pictures.getForKeywords(keywords, function(error, result) {
        if (error) {
          return alert(error);
        } else {
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
      login: function(name, password, fn) {
        return $http.post("/login", {
          username: name,
          password: password
        }).then(function(data) {
          return typeof fn === "function" ? fn(null, data) : void 0;
        }, function(data) {
          return typeof fn === "function" ? fn({
            error: data.error || "Name or password invalid!"
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
      register: function(name, password, fn) {
        return $http.post("/register", {
          username: name,
          password: password
        }).then(function(data) {
          return typeof fn === "function" ? fn(null, data) : void 0;
        }, function(data) {
          return typeof fn === "function" ? fn({
            server: data.error
          }, null) : void 0;
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
      }
    };
  }
]);
;
//# sourceMappingURL=app.js.map