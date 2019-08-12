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
from datetime import timedelta
from flask import make_response, request, current_app
from flask_cors import CORS, cross_origin
from functools import update_wrapper
import json

def crossdomain(origin=None, methods=None, headers=None, max_age=21600,
                attach_to_all=True, automatic_options=True):
    """Decorator function that allows crossdomain requests.
      Courtesy of
      https://blog.skyred.fi/articles/better-crossdomain-snippet-for-flask.html
    """
    if methods is not None:
        methods = ', '.join(sorted(x.upper() for x in methods))
    if headers is not None and not isinstance(headers, list):
        headers = ', '.join(x.upper() for x in headers)
    if not isinstance(origin, list):
        origin = ', '.join(origin)
    if isinstance(max_age, timedelta):
        max_age = max_age.total_seconds()

    def get_methods():
        """ Determines which methods are allowed
        """
        if methods is not None:
            return methods

        options_resp = current_app.make_default_options_response()
        return options_resp.headers['allow']

    def decorator(f):
        """The decorator function
        """
        def wrapped_function(*args, **kwargs):
            """Caries out the actual cross domain code
            """
            if automatic_options and request.method == 'OPTIONS':
                resp = current_app.make_default_options_response()
            else:
                resp = make_response(f(*args, **kwargs))
            if not attach_to_all and request.method != 'OPTIONS':
                return resp

            h = resp.headers
            h['Access-Control-Allow-Origin'] = origin
            h['Access-Control-Allow-Methods'] = get_methods()
            h['Access-Control-Max-Age'] = str(max_age)
            h['Access-Control-Allow-Credentials'] = 'true'
            h['Access-Control-Allow-Headers'] = \
                "Origin, X-Requested-With, Content-Type, Accept, Authorization"
            if headers is not None:
                h['Access-Control-Allow-Headers'] = headers
            return resp

        f.provide_automatic_options = False
        return update_wrapper(wrapped_function, f)
    return decorator

app = Flask(__name__)
cors = CORS(app)

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

    f = open("delay.txt","w")
    print (request.json['delay'])
    f.write(str(request.json['delay']))

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

    f = open("load.txt","w")
    print (request.json['load'])
    #f.write(str(request.json['load']*80000))
    f.write(str(request.json['load']*(8/1000)))

    return jsonify(load), 201

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=10080)
    #app.run(debug=True, host='0.0.0.0', port=3000)
