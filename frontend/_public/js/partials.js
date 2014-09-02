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
'    <li ng-show="Current" class="span12">',
'      <div class="thumbnail">',
'        <!-- here be dragons: how to write this in a if statement--><img src="{{Current.current.url}}" alt="" ng-click="feedback(Current.current._id)" style="cursor:pointer; height:420px; width:560px; margin-left:0px">',
'      </div>',
'      <div class="caption">',
'        <h1>{{Current.current.title}}</h1>',
'        <p>id just for debugging: {{Current.current._id}}</p>',
'        <p><span ng-repeat="tag in Current.current.tags"> {{tag}}</span>',
'        </p>',
'      </div>',
'    </li>',
'  </ul>',
'  <ul class="thumbnails">',
'    <li ng-repeat="picture in Current.recommendations" class="span3">',
'      <div class="thumbnail"><img src="{{picture.url}}" alt="" ng-click="feedback(picture._id)" style="cursor: pointer; height:195px; width:260px;">{{picture.subtitle}}</div>',
'    </li>',
'    <li ng-repeat="picture in Current.trainingset" class="span3">',
'      <div class="thumbnail"><img src="{{picture.url}}" alt="" ng-click="feedback(picture._id)" style="cursor: pointer; height:195px; width:260px;">{{picture.subtitle}}</div>',
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