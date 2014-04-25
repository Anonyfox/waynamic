'use strict'

# Declare app level module which depends on filters, and services
App = angular.module('app', [
  'ngCookies'
  'ngResource'
  'ngRoute'
  'app.controllers'
  'app.directives'
  'app.filters'
  'app.services'
  'partials'
])

App.config([
  '$routeProvider'
  '$locationProvider'

($routeProvider, $locationProvider, config) ->

  $routeProvider

    .when('/', {templateUrl: '/partials/landingpage.html'})
    .when('/pictures', {templateUrl: '/partials/pictures.html'})
    # .when('/home', {templateUrl: '/partials/dashboard.html'})
    .when('/profile', {templateUrl: '/partials/profile.html'})
    .when('/import', {templateUrl: '/partials/import.html'})
    .when('/register', {templateUrl: '/partials/register.html'})
    .when('/login', {templateUrl: '/partials/login.html'})
    .when('/logout', {templateUrl: '/partials/logout.html'})

    # Catch all
    .otherwise({redirectTo: '/'})

  # Without server side support html5 must be disabled.
  $locationProvider.html5Mode(false)
])
