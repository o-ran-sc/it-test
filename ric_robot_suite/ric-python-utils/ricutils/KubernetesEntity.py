#   Copyright (c) 2019 AT&T Intellectual Property.
#   Copyright (c) 2019 Nokia.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

from kubernetes import client, config
import string
import random
import time

# This library provides a massively-simplified interface to the kubernetes
# API library to reduce bloat in robot tests.

class KubernetesEntity(object):
 def __init__(self, namespace):
  self._ns = namespace
  self._annotationGensym = ''.join(random.choice(string.ascii_letters) for _ in range(16))

  # FIXME: this needs to be configurable.
  config.load_kube_config()

  self._k8sApp = client.AppsV1Api()
  self._k8sCore = client.CoreV1Api()
  self._k8sEV1B1 = client.ExtensionsV1beta1Api()

 def Deployment(self, name):
  # this will throw kubernetes.client.rest.ApiException if
  # the deployment doesn't exist.  we'll let robot cope with
  # that.

  # calling code will most likely want to check that
  # deploy.status.replicas == deploy.status.available_replicas
  return self._k8sApp.read_namespaced_deployment(namespace=self._ns,
                                                 name=name)

 def Service(self, name):
  # as above, we'll rely on this to throw if the svc dne.

  # not much to check directly here.  calling code will want
  # to hit svc.spec.cluster_ip:r.spec.ports[0..n] with some
  # sort of health-check request
  return self._k8sCore.read_namespaced_service(namespace=self._ns,
                                               name=name)

 def Pod(self, name):
  return self._k8sCore.read_namespaced_pod(namespace=self._ns,
                                           name=name)

 def Redeploy(self, name, wait=True, timeout=30):
  # restart an existing deployment by doing a nonsense update
  # to its spec.
  body = {'spec':
          {'template':
           {'metadata':
            {'annotations':
             { self._annotationGensym: str(time.time()) }}}}}

  r = self._k8sEV1B1.patch_namespaced_deployment(namespace=self._ns,
                                                 name=name,
                                                 body=body)
  if wait:
   r = self.WaitForDeployment(name, timeout)
  return r

 def WaitForDeployment(self, name, timeout=30):
  # block until a deployment is available
  while timeout > 0:
   dep = self.Deployment(name)
   if dep and dep.status.conditions[-1].type == 'Available':
    return True
   time.sleep(1)
   timeout -= 1
  raise TimeoutError('Kubernetes timeout waiting for ' + name + ' to become available')

