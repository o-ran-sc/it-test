# Getting Started
## Prerequisites
Clone the repo

### build container
./build.sh will create ./build directory, generate documentation using robot.libdoc, copy doc and robot files and build the docker conatiner.
See build.sh for how to run the docker (you will need to edit and copy vm_properties.py and integration_robot_properties.py to your eteshare mount point)

## Development Environment Setup
### Python Installation
You should install 2.7.12: [https://www.python.org/downloads/release/python-2712](https://www.python.org/downloads/release/python-2712)


### Pip Install
Install pip with the get-pip.py file from [https://bootstrap.pypa.io/get-pip.py](https://bootstrap.pypa.io/get-pip.py)
once downloaded run

```
python get-pip.py
```
let it install.

From the desktop, right click the Computer icon.
Choose Properties from the context menu.
Click the Advanced system settings link.
Click Environment Variables. In the section System Variables, click New.
In the New System Variable window, set the name as 'HTTPS\_PROXY' then specify the value of the HTTPS_PROXY environment variable as your proxy. 
Click OK. 
Close all remaining windows by clicking OK.


### Robot Install
Reopen Command prompt window, and run below code to install robot.

```
pip install robotframework
```


### IDE Install
Most further documents will use the RED environment for Robot.
[https://github.com/nokia/RED/releases/download/0.7.0/RED\_0.7.0.20160914115048-win32.win32.x86_64.zip](https://github.com/nokia/RED/releases/download/0.7.0/RED\_0.7.0.20160914115048-win32.win32.x86_64.zip)

Once you install that IDE you probably will want to have a python editor to edit python files better.
Go to Help > Eclipse Marketplace and search for PyDev and click install on PyDev for Eclipse 5.2.0

Once you install that IDE you will need EGit to check in git code.
Go to Help > Eclipse Marketplace and search for Egit git team provider and click install on EGit Git Team Provider 4.5.0

Once you install that IDE you will probably want a json editor to edit json better.
Go to Help > Eclipse Marketplace and search for Json Tools and click install on Json Tools 1.1.0

### Project Setup
Note: You do not need to run these commands every time, only on a library update or initial checkout.

```
./setup.sh  
```

Note that this script will download the chromedriver for the current OS. The default is linux64 which will download the appropriate chromedriver to /usr/local/bin so that it will be in the execution PATH.

Windows and Mac hosts will download into the current working directory. Windows and MAC users will need to ensure that the driver is 
in the execution PATH.


## Robot Project Structure
### Overview
ProjectName - robot

```
`-- robot
    |-- assets - put anything you need as input like json files, cert keys, heat templates
    |   |-- templates - put any json templates in here, you can include subfolders for each component
    |-- doc - docgen.py will put html documentation of the custom keywords here
    |   |-- resources  libdoc of the custom keywords under robot/resources
    |-- library - pip will install Python libraries here
    |   |-- eteutils - pip will install locally-developed Python libraries here
   |-- resources - put any robot resource files aka libraries we write in here
    |   |-- aai
    |   `-- vid
    `-- testsuites - put any robot test suites we write in here
`-- library
    |-- python - put locally-developed Python libraries here, to be copied into eteutilsxo
```    

### Tag Strucutre
Robot uses tags to separate out test cases to run. below are the tags we use

* health - use this for test cases that perform a health check of the environment
* ete - use this for the test cases that are performing an end to end test
# xapptests - use this for test cases that apply to Xapp Mager
* e2mgrtests   - use this for test case that apply to the E2 Mgr 

## Branching Structure
### Overview
Repository Name: it/test/ric_robot_suite

Branching strategy:
```
`-- ric_robot_suite
    |-- master - the main branch and always the latest deployable code. Send a pull to here from feature and Dan or Jerry will approve.
     |-- feature-[XXXXXX] - when you want to make changes you make them here, when you are satisfied send pull request to master
```    

## Executing ETE Testcases
### Overview
Two scripts have been provided in the root of the ete-testsuite project to enable test execution

* runTags.sh - This shell uses Robot [Tags] to drive which tests are executed and is designed for automated testing.
* oneTest.sh - This shell is designed for unit testing of individual .robot files. It accepts a single argument identifying the .robot file in robot/testsuites to execute.
  
#### runTags.sh
For further information on using Robot [Tags], see [http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#configuring-execution] and [http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#simple-patterns]

When executing tests via tags, all of the robot files in the project are scanned for tests cases with the specified tags.

There are 3 flavors of runTags.sh 
* runTags.sh with no arguments. This defaults to the default tag or runTags.sh -i health
* runTags.sh with a single include tag. In this case the -i or --include may be omitted. So runTags.sh ete is the same as runTags.sh -i ete
* runTags.sh with multiple tags. In this case, tags must be accompanied by a -i/--include or -e/--exclude to properly identify the disposition of the tagged testcase.

```
runTags.sh -i health -i ete -e e2mgrtests
```

