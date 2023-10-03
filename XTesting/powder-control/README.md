# About

This project shows how to instantiate a Powder experiment
programmatically via the Powder portal API. 

In [powder/experiment.py](powder/experiment.py), there is a class
`PowderExperiment`, which serves as the main abstraction for starting,
interacting with, and terminating a single Powder experiment. It relies on
[powder/rpc.py](powder/rpc.py) for interacting with the Powder RPC server

In [start-profile.py](start-profile.py), you can see how one might use it
to instantiate a Powder experiment by specifying a given profile name

## Getting Started

In order to run [start-profile.py](start-profile.py) or otherwise use the tools in this
project, you'll need a Powder account to which you've added your public `ssh`
key. If you haven't already done this, you can find instructions
[here](https://docs.powderwireless.net/users.html#%28part._ssh-access%29).
You'll also need to download your Powder credentials. You'll find a button to do
so in the drop-down menu accessed by clicking on your username after logging
into the Powder portal. This will download a file called `cloudlab.pem`, which
you will need later.

You will need to make sure the machine you are using has `python3` installed, as well as
the packages in [requirements.txt](requirements.txt). You can install the
packages by doing

```bash
pip install -r requirements.txt
```

Whatever machine you are using to run [start-profile.py](start-profile.py), it will need a
local copy of the `cloudlab.pem` file you downloaded earlier.

### Running the Example

The RPC client that `PowderExperiment` relies on to interact with the Powder RPC
server expects some environment variables to be set. If your private `ssh` key
is encrypted, the key password needs to be set in an environment variable as
well, unless you have already started `ssh-agent`.

If your ssh key is encrypted:

```bash
set +o history
PROJECT=your_project_name PROFILE=your_profile_name \
USER=your_powder_username PWORD=your_powder_password \
CERT=/path/to/your/cloulab.pem KEYPWORD=your_ssh_key_password ./start-profile.py
```

If not:

```bash
set +o history
PROJECT=your_project_name PROFILE=your_profile_name \
USER=your_powder_username PWORD=your_powder_password \
CERT=/path/to/your/cloulab.pem ./start-profile.py
```

The `set +o history` command will keep these passwords out of your `bash`
history (assuming you're using `bash`). The PROJECT and PROFILE environment
variables are optional, as by default it will use the 'osc' project which is
dedicated to the OSC community usage, and 'ubuntu-20' profile for the widely
used Ubuntu 20.04 image.

It can take more than 30 minutes for instantiating a profile provided to
[start-profile.py](start-profile.py) to complete, but you'll see intermittent messages on
`stdout` indicating progress and logging results. In some cases, the Powder
resources required by [start-profile.py](start-profile.py) might not be available. If so,
you'll see a log message that indicates as much and the script will exit; you
can look at the [Resource Availability](https://www.powderwireless.net/resinfo.php)
page on the Powder portal to see the status of the required instance. After
completion, the script will exit with a message about failure/success.
