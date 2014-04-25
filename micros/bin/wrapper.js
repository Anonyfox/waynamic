#!/usr/bin/env node
require('../node_modules/coffee-script/register')
var module_name = process.argv[2]
if (!(/^micros-(.*)/).test(process.argv[2])) {
  module_name = 'micros-' + process.argv[2]
}
require(process.cwd() + '/node_modules/' + module_name).$deamon()