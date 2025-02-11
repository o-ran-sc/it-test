# it/test

This repository contains tools for end-to-end testing of the RIC and O-Cloud. Among the included tools:

Repository Structure:
- docs/
- releases/
- ric_benchmarking/
- ric_robot_suite/ : implementations of the Robot Framework
(robotframework.org) to enable end-to-end test automation for
development and integration testing.
- simulators/ : an implementation of the gNodeB E2 interface to allow
testing without a live gNodeB and a workload generator to exercise the
interfaces between XApps
- test_scripts/
- XTesting/

These components generally assume a deployed and running RIC.

See the component subdirectories for documentation on the components themselves.
