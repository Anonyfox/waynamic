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
'  <select ng-model="users.current" ng-options="u.name for u in users.list" ng-change="changeSelectedUser(users.current)">',
'  </select>',
'</form>',''].join("\n"));
}])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/partials/pictures.html', [
'',
'<div ng-if="users.current._id == -1">',
'  <h3>Please choose a user !</h3>',
'</div>',
'<div ng-if="users.current._id != -1">',
'  <div id="pictures-view" ng-controller="PicturesCtrl">',
'    <div ng-if="Current.current.url" class="text-center"><img ng-src="{{Current.current.url}}" alt="" ng-click="feedback(Current.current._id)" style="cursor:pointer;">',
'    </div>',
'    <hr>',
'    <ul class="thumbnails">',
'      <li ng-repeat="picture in Current.recommendations" style="background-color: #FFF7F0;" class="span3">',
'        <div class="thumbnail text-center"><img ng-src="{{picture.url}}" alt="" ng-click="feedback(picture._id)" style="cursor: pointer; height:195px; width:260px;">{{picture.subtitle}}</div>',
'      </li>',
'      <li ng-repeat="picture in Current.trainingset" style="background-color: #E8F6FF;" class="span3">',
'        <div class="thumbnail text-center"><img ng-src="{{picture.url}}" alt="" ng-click="feedback(picture._id)" style="cursor: pointer; height:195px; width:260px;">{{picture.subtitle}}</div>',
'      </li>',
'    </ul>',
'  </div>',
'</div>',''].join("\n"));
}])
.run(['$templateCache', function($templateCache) {
  return $templateCache.put('/partials/profile.html', [
'',
'<div ng-controller="ProfileCtrl">',
'  <h1 class="text-center">{{users.current.name}}</h1>',
'  <div style="background: rgba(255,255,255,0.7); margin-bottom: 20px;" class="text-center">',
'    <h3>Friends: {{users.currentFriends.length}}</h3>',
'    <button ng-click="switchUserTo(f._id)" ng-repeat="f in users.currentFriends" style="margin: 5px;" class="btn btn-link"><i class="fa fa-user"></i> {{f.firstName}} {{f.lastName}}</button>',
'  </div>',
'  <div class="row">',
'    <div ng-repeat="m in users.currentHistory" class="span4">',
'      <div style="background: rgba(255,255,255,0.5); margin-bottom: 20px;" class="media"><a class="pull-left"><img ng-src="{{m.url}}" style="height: 75px; width: 75px;" class="media-object"></a>',
'        <div class="media-body">',
'          <h4 class="media-heading">{{m.title | shortText}}</h4>',
'          <p>clicked on {{m.updated | date : \'shortDate\'}}</p>',
'        </div>',
'      </div>',
'    </div>',
'  </div>',
'</div>',''].join("\n"));
}]);