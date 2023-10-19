#!/usr/bin/env python3
import json
import logging
import sys
import time

import xmltodict

import powder.rpc as prpc
import powder.ssh as pssh


class PowderExperiment:
    """Represents a single powder experiment. Can be used to start, interact with,
    and terminate the experiment. After an experiment is ready, this object
    holds references to the nodes in the experiment, which can be interacted
    with via ssh.

    Args:
        experiment_name (str): A name for the experiment. Must be less than 16 characters.
        project_name (str): The name of the Powder Project associated with the experiment.
        profile_name (str): The name of an existing Powder profile you want to use for the experiment.

    Attributes:
        status (int): Represents the last known status of the experiment as
            retrieved from the Powder RPC servqer.
        nodes (dict of str: Node): A lookup table mapping node ids to Node instances
            in the experiment.
        experiment_name (str)
        project_name (str)
        profile_name (str)

    """

    EXPERIMENT_NOT_STARTED = 0
    EXPERIMENT_PROVISIONING = 1
    EXPERIMENT_PROVISIONED = 2
    EXPERIMENT_READY = 3
    EXPERIMENT_FAILED = 4
    EXPERIMENT_NULL = 5

    POLL_INTERVAL_S = 20
    PROVISION_TIMEOUT_S = 1800
    MAX_NAME_LENGTH = 16

    def __init__(self, experiment_name, project_name, profile_name):
        if len(experiment_name) > 16:
            logging.error('Experiment name {} is too long (cannot exceed {} characters)'.format(experiment_name,
                                                                                                self.MAX_NAME_LENGTH))
            sys.exit(1)

        self.experiment_name = experiment_name
        self.project_name = project_name
        self.profile_name = profile_name
        self.status = self.EXPERIMENT_NOT_STARTED
        self.nodes = dict()
        self._manifests = None
        self._poll_count_max = self.PROVISION_TIMEOUT_S // self.POLL_INTERVAL_S
        self.ipv4 = None
        logging.info('initialized experiment {} based on profile {} under project {}'.format(experiment_name,
                                                                                             profile_name,
                                                                                             project_name))

    def start_and_wait(self):
        """Start the experiment and wait for READY or FAILED status."""
        logging.info('starting experiment {}'.format(self.experiment_name))
        rval, response = prpc.start_experiment(self.experiment_name,
                                               self.project_name,
                                               self.profile_name)
        if rval == prpc.RESPONSE_SUCCESS:
            self._get_status()

            poll_count = 0
            logging.info('self.still_provisioning: {}'.format(self.still_provisioning))
            while self.still_provisioning and poll_count < self._poll_count_max:
                logging.info('waiting for provision process done')
                self._get_status()
                time.sleep(self.POLL_INTERVAL_S)
        else:
            self.status = self.EXPERIMENT_FAILED
            logging.info(response)

        return self.status

    def terminate(self):
        """Terminate the experiment. All allocated resources will be released."""
        logging.info('terminating experiment {}'.format(self.experiment_name))
        rval, response = prpc.terminate_experiment(self.project_name, self.experiment_name)
        if rval == prpc.RESPONSE_SUCCESS:
            self.status = self.EXPERIMENT_NULL
        else:
            logging.error('failed to terminate experiment')
            logging.error('output {}'.format(response['output']))

        return self.status

    def _get_manifests(self):
        """Get experiment manifests, translate to list of dicts."""
        rval, response = prpc.get_experiment_manifests(self.project_name,
                                                       self.experiment_name)
        if rval == prpc.RESPONSE_SUCCESS:
            response_json = json.loads(response['output'])
            self._manifests = [xmltodict.parse(response_json[key]) for key in response_json.keys()]
            logging.info('got manifests')
        else:
            logging.error('failed to get manifests')

        return self

    def _parse_manifests(self):
        """Parse experiment manifests and add nodes to lookup table."""
        for manifest in self._manifests:
            logging.info('parsed manifest:{}'.format(manifest))
            nodes = manifest['rspec']['node']
            logging.info('parsed manifest nodes:{}'.format(nodes))
            client_id = nodes['@client_id']
            logging.info('parsed manifest client_id:{}'.format(client_id))
            host = nodes['host']
            logging.info('parsed manifest host:{}'.format(host))
            hostname = host['@name']
            logging.info('parsed manifest hostname:{}'.format(hostname))
            self.ipv4 = host['@ipv4']
            logging.info('parsed manifest ipv4:{}'.format(self.ipv4))
            for node in nodes:
                logging.info('parsed manifest node:{}'.format(node))
                # only need to add nodes with public IP addresses for now
#                try:
#                    hostname = node['host']['@name']
#                    ipv4 = node['host']['@ipv4']
#                    client_id = nodes['@client_id']
#                    self.nodes[client_id] = Node(client_id=client_id, ip_address=ipv4,
#                                                 hostname=hostname)
#                except KeyError:
#                    pass
#
        return self

    def _get_status(self):
        """Get experiment status and update local state. If the experiment is ready, get
        and parse the associated manifests.

        """
        rval, response = prpc.get_experiment_status(self.project_name,
                                                    self.experiment_name)
        if rval == prpc.RESPONSE_SUCCESS:
            output = response['output']
            #if output == 'Status: ready\n':
            if "ready" in output:
                self.status = self.EXPERIMENT_READY
                self._get_manifests()._parse_manifests()
            #elif output == 'Status: provisioning\n':
            elif "provisioning" in output:
                self.status = self.EXPERIMENT_PROVISIONING
            #elif output == 'Status: provisioned\n':
            elif "provisioned" in output:
                self.status = self.EXPERIMENT_PROVISIONED
            #elif output == 'Status: failed\n':
            elif "failed" in output:
                self.status = self.EXPERIMENT_FAILED

            logging.info('status is {}'.format(self.status))
            self.still_provisioning = self.status in [self.EXPERIMENT_PROVISIONING,
                                                      self.EXPERIMENT_PROVISIONED]
            logging.info('experiment status is {}'.format(output.strip()))
        else:
            logging.error('failed to get experiment status')

        return self


class Node:
    """Represents a node on the Powder platform. Holds an SSHConnection instance for
    interacting with the node.

    Attributes:
        client_id (str): Matches the id defined for the node in the Powder profile.
        ip_address (str): The public IP address of the node.
        hostname (str): The hostname of the node.
        ssh (SSHConnection): For interacting with the node via ssh through pexpect.

    """
    #def __init__(self, client_id, ip_address, hostname):
    def __init__(self, ip_address):    
        #self.client_id = client_id
        self.ip_address = ip_address
        #self.hostname = hostname
        self.ssh = pssh.SSHConnection(ip_address=self.ip_address)
