angular.module('partials', [])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/partials/import.html', [
'',
'<h1>mighty social networks import here.</h1>',''].join("\n"));
}])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/partials/landingpage.html', [
'',
'<h1>awesome landingpage here.</h1>',''].join("\n"));
}])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/partials/login.html', [
'',
'<div ng-controller="LoginCtrl">',
'  <h1>User Login</h1>',
'  <div class="row">',
'    <div class="span3">Login as User with ID:</div>',
'    <div class="span3">',
'      <input type="text" ng-model="newUser.nodeId">',
'    </div>',
'    <div class="span1">',
'      <button ng-click="loginNewUser()">Login</button>',
'    </div>',
'  </div>',
'</div>',''].join("\n"));
}])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/partials/logout.html', [
'',
'<h1>logout placeholder</h1>',''].join("\n"));
}])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/partials/nav.html', [
'',
'<ul class="nav">',
'  <li ng-class="getClass(\'/pictures\')"><a ng-href="#/pictures"><i class="fa fa-picture-o"></i> Pictures</a></li>',
'</ul>',''].join("\n"));
}])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/partials/pictures.html', [
'',
'<div ng-controller="PicturesCtrl">',
'  <ul class="thumbnails">',
'    <li ng-repeat="picture in currentPictures" class="span4">',
'      <div class="thumbnail"><img src="{{picture.url}}" alt="" ng-click="nextPicturesByUrl(picture.url)" style="cursor: pointer; height:240px; width:360px;">',
'        <h3>{{picture.title}}</h3>',
'      </div>',
'    </li>',
'  </ul>',
'</div>',''].join("\n"));
}])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/partials/profile.html', [
'',
'<h1>awesome profile page here.</h1>',
'<h3>settings and stuff.</h3>',''].join("\n"));
}])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/partials/register.html', [
'',
'<h1>registration page here</h1>',''].join("\n"));
}])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/partials/todo.html', [
'',
'<div ng-app="ng-app">',
'  <h2>Todo</h2>',
'  <div ng-controller="TodoCtrl"><span>{{remaining()}} of {{todos.length}} remaining</span> [<a href="" ng-click="archive()">archive</a>]',
'    <ul class="unstyled">',
'      <li ng-repeat="todo in todos">',
'        <label class="checkbox inline">',
'          <input type="checkbox" ng-model="todo.done"><span class="done{{todo.done}}">{{todo.text}}</span>',
'        </label>',
'      </li>',
'    </ul>',
'    <form ng-submit="addTodo()" class="form-inline">',
'      <p>',
'        <input type="text" ng-model="todoText" size="30" placeholder="add new todo here">',
'        <input type="submit" value="add" class="btn btn-primary">',
'      </p>',
'    </form>',
'  </div>',
'</div>',''].join("\n"));
}]);