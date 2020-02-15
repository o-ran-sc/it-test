#!/bin/bash

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



#
# setup : script to setup required runtime environment. This script can be run again to update anything
# this should stay in your project directory


# save console output in setup_<timestamp>.log file in project directory
timestamp=$(date +"%m%d%Y_%H%M%S")
LOG_FILE=setup_$timestamp.log
exec > >(tee -a ${LOG_FILE} )
exec 2> >(tee -a ${LOG_FILE} >&2)


# get the path
path=$(pwd)
pip install \
--no-cache-dir \
--exists-action s \
--target="$path/robot/library" \
'selenium<=3.0.0' \
'requests==2.11.1' \
'robotframework-selenium2library==1.8.0' \
'robotframework-databaselibrary==0.8.1' \
'robotframework-extendedselenium2library==0.9.1' \
'robotframework-requests==0.5.0' \
'robotframework-sshlibrary==2.1.2' \
'robotframework-sudslibrary==0.8' \
'robotframework-ftplibrary==1.3' \
'robotframework-rammbock==0.4.0.1' \
'deepdiff==2.5.1' \
'dnspython==1.15.0' \
'robotframework-httplibrary==0.4.2' \
'robotframework-archivelibrary==0.3.2' \
'PyYAML==3.12' \
'kubernetes==9.0.0' \
'pick==0.6.4' \
'robotframework-kafkalibrary==0.0.2'

# dk3239: HACK
#  for some reason the parent __init__.py isn't getting installed
#  with google-auth.  This is a quick fix until I figure out which
#  package (hint: it's not "google") owns it.
touch $path/robot/library/google/__init__.py

# get the git for the eteutils you will need to add a private key to your ssh before this
if [ -d $path/testsuite/eteutils ]
then
    # Support LF build location
	cd $path/testsuite/eteutils
else
	cd ~
	git config --global http.sslVerify false
	if [ -d ~/python-testing-utils ]
	then
		cd python-testing-utils
		git pull origin master
	else
		git clone -b 3.0.1-ONAP https://gerrit.onap.org/r/testsuite/python-testing-utils.git
		cd python-testing-utils
	fi
fi

# install python-testing-utils from current directory (.)
pip install \
--no-cache-dir \
--upgrade \
--exists-action s \
--target="$path/robot/library" .


# install the ric project python scripts
# from /var/opt/RIC/ric-python-utils
# to   /var/opt/RIC/robot/library/ricutils
if [ -d $path/ric-python-utils ]
then
    # Support LF build location
	cd $path/ric-python-utils
    # install ric-python-utils from current directory (.)
        pip install \
        --no-cache-dir \
        --upgrade \
        --exists-action s \
        --target="$path/robot/library" .
fi

# NOTE: Patch to incude explicit install of paramiko to 2.0.2 to work with sshlibrary 2.1.2
# This should be removed on new release of paramiko (2.1.2) or sshlibrary
# https://github.com/robotframework/SSHLibrary/issues/157
pip install \
--no-cache-dir \
--target="$path/robot/library" \
-U 'paramiko==2.0.2'


# Go back to execution folder
cd $path

# if the script is running during the image build skip the rest of it
# as required software is installed already.
if $BUILDTIME
then
	# we need to update PATH with APT-GET installed chromium-chromedriver
	echo "Adding in-container chromedriver to PATH"
	ln -s /usr/lib/chromium-browser/chromedriver /usr/local/bin/chromedriver
else	
	#
	# Get the appropriate chromedriver. Default to linux64
	#
	CHROMEDRIVER_URL=http://chromedriver.storage.googleapis.com/2.43
	CHROMEDRIVER_ZIP=chromedriver_linux64.zip
	CHROMEDRIVER_TARGET=chromedriver.zip

	# Handle mac and windows
	OS=`uname -s`
	case $OS in
	  MINGW*_NT*)
	  	CHROMEDRIVER_ZIP=chromedriver_win32.zip
	  	;;
	  Darwin*)
	  	CHROMEDRIVER_ZIP=chromedriver_mac64.zip
	  	;;
	  *) echo "Defaulting to Linux 64" ;;
	esac

	if [ $CHROMEDRIVER_ZIP == 'chromedriver_linux64.zip' ]
	then
	    curl $CHROMEDRIVER_URL/$CHROMEDRIVER_ZIP -o $CHROMEDRIVER_TARGET
		unzip chromedriver.zip -d /usr/local/bin
	else
	    curl $CHROMEDRIVER_URL/$CHROMEDRIVER_ZIP -o $CHROMEDRIVER_TARGET
		unzip $CHROMEDRIVER_TARGET
	fi
	rm -rf $CHROMEDRIVER_TARGET
fi

#
# Install kafkacat : https://github.com/edenhill/kafkacat
#
OS=`uname -s`
case $OS in
	Darwin)
		brew install kafkacat ;;
	Linux)
		apt-get -y install kafkacat
esac
#
# Install protobuf
#
OS=`uname -s`
case $OS in
        Darwin)
                brew install protobuf ;;
        Linux)
                apt-get -y install protobuf-compiler
esac
