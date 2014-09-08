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
'</ul>',
'<form class="navbar-form pull-right">',
'  <select ng-model="selectedUser" ng-options="u.name for u in users.list" ng-change="changeSelectedUser(selectedUser)">',
'  </select>',
'</form>',''].join("\n"));
}])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/partials/pictures.html', [
'',
'<div ng-if="users.current._id == 0">',
'  <h3>Please choose a user !</h3>',
'</div>',
'<div ng-if="users.current._id != 0">',
'  <div ng-controller="PicturesCtrl">',
'    <div ng-if="Current.current.url">',
'      <ul class="thumbnails">',
'        <li ng-show="Current" class="span12">',
'          <div class="thumbnail">',
'            <!-- here be dragons: how to write this in a if statement--><img ng-src="{{Current.current.url}}" alt="" ng-click="feedback(Current.current._id)" style="cursor:pointer; height:300px; margin-left:0px; margin-right:20px; float:left;">',
'            <div class="caption">',
'              <h1>{{Current.current.title}}</h1><span ng-repeat="tag in Current.current.tags" style="margin:5px; padding:5px;" class="label">{{tag}}</span>',
'            </div>',
'            <div style="clear:left;"></div>',
'          </div>',
'        </li>',
'      </ul>',
'    </div>',
'    <ul class="thumbnails">',
'      <li ng-repeat="picture in Current.recommendations" class="span3">',
'        <div class="thumbnail"><img src="{{picture.url}}" alt="" ng-click="feedback(picture._id)" style="cursor: pointer; height:195px; width:260px;">{{picture.subtitle}}</div>',
'      </li>',
'      <li ng-repeat="picture in Current.trainingset" class="span3">',
'        <div class="thumbnail"><img ng-src="{{picture.url}}" alt="" ng-click="feedback(picture._id)" style="cursor: pointer; height:195px; width:260px;">{{picture.subtitle}}</div>',
'      </li>',
'    </ul>',
'  </div>',
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
}]);