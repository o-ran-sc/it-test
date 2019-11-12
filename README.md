# RIC end-to-end (E2E) deployment and testing: 
1. Clone the it_dep and it_test folders on your VM
2. Install kubernetes using the script in it_dep_kubernetes/setup-1node-k8s.sh
3. Install the RIC using the script in it_dep_ricplt/ric_install.sh
4. Copy robot_install.sh from it_test_ric_robot_suite_helm_ into it_dep_ricplt/
5. cd into it_dep_ricplt and run robot_install.sh. It will create a softlink to the it_test_ric_robot_suite helm director and do the helm install of rig-robot from it_dep_ricplt
6. The command “kubectl -n ricplatform get pods” will show the additional pod for ric-robot.
7. cd into it_test_ric_robot_suite_helm_ric-robot and run  ./ete.sh health to verify that the RIC is ready and deployed. 


	
