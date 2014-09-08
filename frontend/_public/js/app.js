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
    if (!$rootScope.Current.list.length) {
      Pictures.getInitialPics();
    }
    $scope.$watch("users.current._id", function(oldValue, newValue) {
      if (oldValue !== newValue) {
        return Pictures.getInitialPics();
      }
    });
    return $scope.feedback = function(_id) {
      var postBody;
      $("#pictures-view").hide();
      postBody = _.extend($rootScope.Current, {
        clicked: _id
      });
      return Pictures.getPicsByFeedback(postBody, function(error, result) {
        return $("#pictures-view").fadeIn();
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
  "$http", "$rootScope", "User", function($http, $rootScope, User) {
    $rootScope.Current = {
      list: [],
      current: {
        _id: 0,
        url: ""
      }
    };
    return {
      getPicsByFeedback: function(postBody, fn) {
        return $http.post("/users/" + (User.currentUserId()) + "/pictures", postBody).then(function(data) {
          $rootScope.Current = data.data;
          return typeof fn === "function" ? fn(null, data.data) : void 0;
        }, function(data) {
          return typeof fn === "function" ? fn({
            error: "Something went wrong. Flickr unavailable?"
          }, null) : void 0;
        });
      },
      getInitialPics: function(fn) {
        return $http.get("/users/" + (User.currentUserId()) + "/pictures").then(function(data) {
          $rootScope.Current = data.data;
          return typeof fn === "function" ? fn(null, data.data) : void 0;
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