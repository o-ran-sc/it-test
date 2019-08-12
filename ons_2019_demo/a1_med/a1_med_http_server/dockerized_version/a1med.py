#!flask/bin/python
#
#
# Copyright 2019 AT&T Intellectual Property
# Copyright 2019 Nokia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from flask import Flask, jsonify, request
import json

app = Flask(__name__)



@app.route('/a1ric/metrics', methods=['GET'])
def get_metrics():
    with open('metrics.json') as json_file:
        metrics = json.load(json_file)
    return jsonify(metrics)

@app.route('/a1ric/delay', methods=['GET'])
def get_delay():
    with open('delay.json') as json_file:
        delay = json.load(json_file)
    return jsonify(delay)

@app.route('/a1ric/load', methods=['GET'])
def get_load():
    with open('load.json') as json_file:
        load = json.load(json_file)
    return jsonify(load)

@app.route('/a1ric/delay', methods=['PUT'])
def write_delay_file():
    if not request.json or not 'delay' in request.json:
        abort(400)
    delay = {
        'delay': request.json['delay'],
    }
    delay_json = json.dumps(delay)
    f = open("delay.json","w")
    f.write(delay_json)
    return jsonify(delay), 201

@app.route('/a1ric/load', methods=['PUT'])
def write_load_file():
    if not request.json or not 'load' in request.json:
        abort(400)
    load = {
        'load': request.json['load'],
    }
    load_json = json.dumps(load)
    f = open("load.json","w")
    f.write(load_json)
    return jsonify(load), 201

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=10080)
