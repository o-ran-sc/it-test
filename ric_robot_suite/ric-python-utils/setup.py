################################################################################
#   Copyright (c) 2019 AT&T Intellectual Property.                             #
#   Copyright (c) 2019 Nokia.                                                  #
#                                                                              #
#   Licensed under the Apache License, Version 2.0 (the "License");            #
#   you may not use this file except in compliance with the License.           #
#   You may obtain a copy of the License at                                    #
#                                                                              #
#       http://www.apache.org/licenses/LICENSE-2.0                             #
#                                                                              #
#   Unless required by applicable law or agreed to in writing, software        #
#   distributed under the License is distributed on an "AS IS" BASIS,          #
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
#   See the License for the specific language governing permissions and        #
#   limitations under the License.                                             #
################################################################################
from setuptools import setup

setup(
    name='python-oran-osc-ric-utils',            # This is the name of your PyPI-package.
    version='0.1',                          # Update the version number for new releases
    description='Scripts written to be used during ete testing',    # Info about script
    install_requires=['robotframework'], # what we need
    packages=['ricutils'],       # The name of your scipts package
    package_dir={'ricutils': 'ricutils' } # The location of your scipts package
)
