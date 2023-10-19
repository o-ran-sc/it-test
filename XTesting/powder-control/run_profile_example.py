#!/usr/bin/env python3
import logging
import mmap
import multiprocessing as mp
import powder.experiment as pexp
import random
import re
import string
import sys
import time
from powder.profile import PowderProfile

class RunTest:
    """Based on the return values from the process that starts a given POWDER profile,
    create ssh connection and run desired commands, e.g., test steps that's already
    published as scripts or pure commands

    """

    TEST_SUCCEEDED   = 0  # all steps succeeded
    TEST_FAILED      = 1  # one of the steps failed
    TEST_NOT_STARTED = 2  # could not instantiate an experiment to run the test on

    def run(self):
        powder_host = PowderProfile()
        # expect the start on a specified profile succeeds and return
        # an IPv4 address to proceed to the next step
        status, ip_address = powder_host.run()

        if not ip_address:
            sys.exit(self.TEST_NOT_STARTED)
        elif self._start_powder_experiment(ip_address):
            sys.exit(self.TEST_FAILED)
        else:    
            sys.exit(self.TEST_SUCCEEDED)

    def _start_powder_experiment(self, ip_address):
        logging.info('Executing ssh commands on host:{}'.format(ip_address))
        node = pexp.Node(ip_address=ip_address)
        ssh_node = node.ssh.open()
        # the example commands shown below are to set up the AI/ML FW from scratch
        ssh_node.command('sudo groupadd docker && sudo usermod -aG docker osc_int')
        ssh_node.close(5)
        ssh_node = node.ssh.open()
        ssh_node.command('git clone https://gerrit.o-ran-sc.org/r/aiml-fw/aimlfw-dep')
        ssh_node.command('cd aimlfw-dep && bin/install_traininghost.sh 2>&1 | tee /tmp/install.log', timeout=1800)
        ssh_node.close(5)

if __name__ == '__main__':
    powdertest = RunTest()
    powdertest.run()
