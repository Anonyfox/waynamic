angular.module('partials', [])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/partials/landingpage.html', [
'',
'<h1>awesome landingpage here.</h1>',''].join("\n"));
}])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/partials/nav.html', [
'',
'<ul class="nav">',
'  <li ng-class="getClass(\'/pictures\')"><a ng-href="#/pictures"><i class="fa fa-picture-o"></i> Pictures</a></li>',
'  <li ng-class="getClass(\'/profile\')"><a ng-href="#/profile"><i class="fa fa-user"></i> Profile</a></li>',
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
'  <div id="pictures-view" ng-controller="PicturesCtrl">',
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
'<div ng-controller="ProfileCtrl">',
'  <h1>{{users.current.firstName}} {{users.current.lastName}}</h1>',
'  <hr>',
'  <h3>Friends: {{17}}</h3>',
'  <div class="well"><a href="#" ng-click="switchUserTo(f._id)" ng-repeat="f in users.current.friends" class="btn">{{f.firstName}} {{f.lastName}}</a></div>',
'  <hr>',
'  <h3>History:</h3>',
'  <div ng-repeat="m in users.current.history" class="media"><a href="#" class="pull-left"><img ng-src="{{m.url}}" class="media-object"></a>',
'    <div class="media-body">',
'      <h4 class="media-heading">{{m.title}}</h4>',
'      <p>clicked on {{m.updated}}</p>',
'    </div>',
'  </div>',
'</div>',''].join("\n"));
}]);