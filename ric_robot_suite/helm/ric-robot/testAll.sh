# script to do all regression tags
# fill in the file path to the override file
#  
OVERRIDE_FILE=__REPLACE_WITH_FILEPATH_TO_OVERRIDE_FILE__
# only need to run demo-k8s.sh once  but doesnt hurt to repeat it
./demo-k8s.sh ricplt init_robot
./ete-k8s.sh ricplt health
./ete-k8s.sh ricplt etetests
sleep 5
./ete-k8s.sh ricplt ci_tests
./ete-k8s.e2sim.sh ricplt e2setup $OVERRIDE_FILE TEST_NODE_B_NAME:AAAA123456
./ete-k8s.e2sim.sh ricplt e2setup_dash $OVERRIDE_FILE TEST_NODE_B_NAME:AAAA123456
./ete-k8s.e2sim.sh ricplt x2setup  $OVERRIDE_FILE TEST_NODE_B_NAME:AAAA123456
./ete-k8s.e2sim.sh ricplt x2setup_dash  $OVERRIDE_FILE TEST_NODE_B_NAME:AAAA123456
