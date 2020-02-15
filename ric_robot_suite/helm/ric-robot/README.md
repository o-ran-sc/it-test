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
#  the test repo needs to be on the same parent path as the dep repo
#  simply run robot_install.sh with an optional override file from this directory
#
#  replace the dashboard ip and port in values.yaml or set the values in the override file
#    from the  r1-kong-platform-kong-proxy
#   dashboardExternalIp:  REPLACE_WITH_EXTERNAL_K8_IP_OF_DASHBOARD
#   dashboardExternalPort:  REPLACE_WITH_NODEPORT_OF_DASHBOARD
#
#   ./robot_install.sh  /root/dep/RECIPE_EXAMPLE/RIC_PLATFORM_RECIPE_EXAMPLE
#
#  remember to run the init_robot tag to complete robot setup
#  cd ric-robot
#      ./demo-k8s.sh ricplt init_robot
#
