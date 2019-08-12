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

import os
import shutil
from robot.libdoc import libdoc

dirpath = os.getcwd()
in_path = os.path.join(dirpath,"robot/resources")
out_path =os.path.join(dirpath,"eteshare/doc/resources")


print in_path
print out_path
exit
#shutil.rmtree(out_path, ignore_errors=True)
for root, dirs, files in os.walk(in_path):
    for file in files:
        splitext = os.path.splitext(file)
        if splitext[1] == '.robot':
            rel_path = os.path.relpath(root, in_path)
            in_file = os.path.join(root, file)
            out_dir = os.path.normpath(os.path.join(out_path, rel_path))
            out_file = os.path.join(out_dir, splitext[0] + '.html')

            if not os.path.exists(out_dir):
                os.makedirs(out_dir)
            libdoc(in_file, out_file, docformat='ROBOT')
