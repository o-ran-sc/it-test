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
import os

logging.basicConfig(
    level=logging.DEBUG,
    format="[%(asctime)s] %(name)s:%(levelname)s: %(message)s"
)


class PowderProfile:
    """Instantiates a Powder experiment based on the provided Powder profile 
    by default the project is 'osc' and the profile is 'ubuntu-20'. 
    It returns the IPv4 address if a profile starts successfully on Powder
    """

    # default Powder experiment credentials
    PROJECT_NAME = 'osc'
    PROFILE_NAME = 'ubuntu-20'
    EXPERIMENT_NAME_PREFIX = 'osctest-'

    SUCCEEDED   = 0  # all steps succeeded
    FAILED      = 1  # on of the steps failed

    def __init__(self, experiment_name=None):
        if experiment_name is not None:
            self.experiment_name = experiment_name
        else:
            self.experiment_name = self.EXPERIMENT_NAME_PREFIX + self._random_string()

        try:
            self.project_name = os.environ['PROJECT']
        except KeyError:
            self.project_name = self.PROJECT_NAME

        try:
            self.profile_name = os.environ['PROFILE']
        except KeyError:
            self.profile_name = self.PROFILE_NAME

    def run(self):
        if not self._start_powder_experiment():
            return self._finish(self.FAILED)
        else:
            return self._finish(self.SUCCEEDED)

    def _random_string(self, strlen=7):
        characters = string.ascii_lowercase + string.digits
        return ''.join(random.choice(characters) for i in range(strlen))

    def _start_powder_experiment(self):
        logging.info('Instantiating Powder experiment...')
        self.exp = pexp.PowderExperiment(experiment_name=self.experiment_name,
                                         project_name=self.project_name,
                                         profile_name=self.profile_name)

        exp_status = self.exp.start_and_wait()
        if exp_status != self.exp.EXPERIMENT_READY:
            logging.error('Failed to start experiment.')
            return False
        else:
            return True

    def _finish(self, test_status):
        if test_status == self.FAILED:
            logging.info('The experiment could not be started... maybe the resources were unavailable.')
            return test_status, None
        elif test_status == self.SUCCEEDED:
            logging.info('The experiment successfully started.')
            return test_status, self.exp.ipv4
