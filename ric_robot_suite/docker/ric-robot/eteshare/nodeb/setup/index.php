<?php
/*
======================================================================
        Copyright (c) 2019 Nokia
        Copyright (c) 2018-2019 AT&T Intellectual Property.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
   implied. See the License for the specific language governing
   permissions andlimitations under the License.
======================================================================
*/
$method = $_SERVER['REQUEST_METHOD'];
$request = explode("/", substr(@$_SERVER['PATH_INFO'], 1));
header('Content-type: application/json');

switch ($method) {
  case 'PUT':
    do_something_with_put($request);  
    break;
  case 'POST':
    do_something_with_post($request);  
    break;
  case 'GET':
    do_something_with_get($request);  
    break;
  default:
    handle_error($request);  
    break;
}

function do_something_with_get() {
    $data = [ 'ranName' => 'nodeB1', 'ranPort' => '879', 'ranIp' => '10.0.0.3' ];
    echo json_encode( $data );
}
function do_something_with_post() {
    $data = [ 'ranName' => 'nodeB1', 'ranPort' => '879', 'ranIp' => '10.0.0.3' ];
    echo json_encode( $data );
}

function handle_error() {
   echo "Method not found";
}

?>
