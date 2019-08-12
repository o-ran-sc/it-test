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
  case 'GET':
    do_something_with_get($request);  
    break;
  default:
    handle_error($request);  
    break;
}

function do_something_with_get() {
    $data = [ 'name' => 'DemoXapp1', 'status' => 'started', 'version' => '1.2.3', 
		 'instances' => [ 'name' => 'DemoXapp1', 'id' => 101, 'status' => 'started' , 
		 'ip' => '192.168.0.1', 'port' => 23300 , 'txMessages' => [ 'ControlIndication' ], 
		 'rxMessages' => [ 'LoadIndication' ] ] ];
    echo json_encode( $data );
}

function handle_error() {
   echo "Method not found";
}

?>
