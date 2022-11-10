# XTesting-demo

This repo is to demonstrate the XTesting work flow against the deployment of the OSC RIC platform followed up with a health check test case.

To run the demo, clone the repo on the XTesting host and run the following command:

sudo ./install_dependencies.sh		# if the XTesting is not yet set up on the host
sudo ./demo.sh target-ip private-key-file-path [working-directory]
