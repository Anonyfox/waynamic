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
]).controller('NavCtrl', [
  '$scope', 'User', function($scope, User) {
    $scope.changeSelectedUser = function(u) {
      return User.setCurrentUser(u);
    };
    return User.getAllUsers();
  }
]).controller('PicturesCtrl', [
  '$scope', '$rootScope', 'Pictures', 'User', function($scope, $rootScope, Pictures, User) {
    $scope.Current = Pictures.getInitialPics(function(error, result) {
      if (error) {
        return alert(error);
      }
      return $scope.Current = result.data;
    });
    $scope.$watch("users.current._id", function(oldValue, newValue) {
      if (oldValue !== newValue) {
        return $scope.Current = Pictures.getInitialPics(function(error, result) {
          if (error) {
            return alert(error);
          }
          return $scope.Current = result.data;
        });
      }
    });
    return $scope.feedback = function(_id) {
      var postBody;
      postBody = _.extend($scope.Current, {
        clicked: _id
      });
      return Pictures.getPicsByFeedback(postBody, function(error, result) {
        if (error) {
          return alert(error);
        }
        return $scope.Current = result.data;
      });
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
  "$http", "$rootScope", function($http, $rootScope) {
    $rootScope.users = {
      list: [],
      current: {
        _id: 0,
        name: ""
      }
    };
    return {
      users: function() {
        return $rootScope.users;
      },
      currentUser: function() {
        return $rootScope.users.current;
      },
      currentUserId: function() {
        return $rootScope.users.current._id;
      },
      setCurrentUser: function(u) {
        return $rootScope.users.current = u;
      },
      getAllUsers: function(fn) {
        return $http.get("/users").then(function(data) {
          $rootScope.users.list = _.map(data.data, function(u) {
            return {
              _id: u._id,
              name: "#" + u._id + " " + u.firstName + " " + u.lastName
            };
          });
          return typeof fn === "function" ? fn(null, $rootScope.users.list) : void 0;
        }, function(data) {
          return typeof fn === "function" ? fn(null, []) : void 0;
        });
      }
    };
  }
]).service("Pictures", [
  "$http", "User", function($http, User) {
    return {
      getPicsByFeedback: function(postBody, fn) {
        return $http.post("/users/" + (User.currentUserId()) + "/pictures", postBody).then(function(data) {
          return typeof fn === "function" ? fn(null, data) : void 0;
        }, function(data) {
          return typeof fn === "function" ? fn({
            error: "Something went wrong. Flickr unavailable?"
          }, null) : void 0;
        });
      },
      getInitialPics: function(fn) {
        return $http.get("/users/" + (User.currentUserId()) + "/pictures").then(function(data) {
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