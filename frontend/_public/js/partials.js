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
'<h1>user login form here</h1>',''].join("\n"));
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
'  <li ng-class="getClass(\'/profile\')"><a ng-href="#/profile"><i class="fa fa-user"></i> Profile</a></li>',
'  <li ng-class="getClass(\'/import\')"><a ng-href="#/import"><i class="fa fa-exchange"></i> Import</a></li>',
'</ul>',
'<ul class="nav pull-right">',
'  <li ng-class="getClass(\'/register\')"><a ng-href="#/register"><i class="fa fa-pencil"></i> Register</a></li>',
'  <li ng-class="getClass(\'/login\')"><a ng-href="#/login"><i class="fa fa-sign-in"></i> Login</a></li>',
'  <li ng-class="getClass(\'/logout\')"><a ng-href="#/logout"><i class="fa fa-sign-out"></i> Logout</a></li>',
'</ul>',''].join("\n"));
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
}])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/partials/pictures.html', [
'',
'<div ng-controller="PicturesCtrl">',
'  <ul class="thumbnails">',
'    <li ng-repeat="picture in currentPictures" class="span4">',
'      <div class="thumbnail"><img src="{{picture.url}}" alt="" ng-click="nextPicturesByUrl(picture.url)" style="cursor: pointer;">',
'        <h3>{{picture.title}}</h3>',
'        <p> ',
'          <button ng-click="nextPicturesByTag(tag)" ng-repeat="tag in picture.tags" class="btn btn-link">{{tag}}</button>',
'        </p>',
'      </div>',
'    </li>',
'  </ul>',
'</div>',''].join("\n"));
}]);