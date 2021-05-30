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
import sys
import string
import random
import time
import ssl
import asyncio
import websockets
import urllib.parse

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

 def Deployment(self, name, namespace=None):
  # this will throw kubernetes.client.rest.ApiException if
  # the deployment doesn't exist.  we'll let robot cope with
  # that.

  # calling code will most likely want to check that
  # deploy.status.replicas == deploy.status.available_replicas
  return self._k8sApp.read_namespaced_deployment(namespace=namespace or self._ns,
                                                 name=name)

 def StatefulSet(self, name, namespace=None):
  # as above, but for statefulsets, and with the assumption
  # that the typical check here sfst.replicas == sfst.ready_replicas
  return self._k8sApp.read_namespaced_stateful_set(namespace = namespace or self._ns,
                                                   name=name)

 def Service(self, name, namespace=None):
  # as above, we'll rely on this to throw if the svc dne.

  # not much to check directly here.  calling code will want
  # to hit svc.spec.cluster_ip:r.spec.ports[0..n] with some
  # sort of health-check request
  return self._k8sCore.read_namespaced_service(namespace=namespace or self._ns,
                                               name=name)

 def Pod(self, name, namespace=None):
  return self._k8sCore.read_namespaced_pod(namespace=namespace or self._ns,
                                           name=name)

 def Redeploy(self, name, wait=True, timeout=30, namespace=None):
  # restart an existing deployment by doing a nonsense update
  # to its spec.
  body = {'spec':
          {'template':
           {'metadata':
            {'annotations':
             { self._annotationGensym: str(time.time()) }}}}}

  r = self._k8sEV1B1.patch_namespaced_deployment(namespace=namespace or self._ns,
                                                 name=name,
                                                 body=body)
  if wait:
   r = self.WaitForDeployment(name, timeout, namespace=namespace or self._ns)
  return r

 def WaitForDeployment(self, name, timeout=30, namespace=None):
  # block until a deployment is available
  while timeout > 0:
   dep = self.Deployment(name, namespace=namespace or self._ns)
   if dep and dep.status.conditions[-1].type == 'Available':
    return True
   time.sleep(1)
   timeout -= 1
  raise TimeoutError('Kubernetes timeout waiting for ' + name + ' to become available')

 def RetrievePodsForDeployment(self, name, namespace=None):
  # return the pod names associated with a deployment
  d = self.Deployment(name, namespace or self._ns)
  labels = d.spec.selector.match_labels
  pods = self._k8sCore.list_namespaced_pod(namespace or self._ns,
                                           label_selector=",".join(map(lambda k: k + "=" + labels[k],
                                                                       labels)))
  return list(map(lambda i: i.metadata.name, pods.items))

 def RetrieveLogForPod(self, pod, container='', tail=sys.maxsize, namespace=None):
  # not really an "entity" thing per se, but.
  # kinda want to include timestamps, but i don't have a use case for them.
  return self._k8sCore.read_namespaced_pod_log(namespace=namespace or self._ns,
                                               name=pod,
                                               container=container,
                                               tail_lines=tail).split('\n')[0:-1]

 def ExecuteCommandInPod(self, pod, cmd, strip_newlines=True, namespace=None):
   # near as i can tell, the python k8s client doesn't implement
   # 'kubectl exec'.  this is near enough for our purposes.
   # 'cmd' is an argv list.
   channels={1: 'stdout', 2: 'stderr', 3: 'k8s'}
   output={'stdout': [], 'stderr': [], 'k8s': []}
   path='/api/v1/namespaces/%s/pods/%s/exec?%s&stdin=false&stderr=true&stdout=true&tty=false' % \
        (namespace or self._ns, pod, urllib.parse.urlencode({'command': cmd}, doseq=True))
   # we could probably cache and reuse the sslcontext, but meh, we're not
   # after performance here.
   ctx=ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
   c = client.Configuration()

   async def ExecCoroutine():
      # base64.channel.k8s.io is also a valid subprotocol, but i don't see any
      # reason to support it.
      async with websockets.connect(uri,\
                                    ssl=ctx,\
                                    subprotocols=["channel.k8s.io"],\
                                    extra_headers=c.api_key) as ws:
        async for message in ws:
           if message[0] in channels and (not strip_newlines or len(message) > 1):
             # we probably should throw up if we get an unrecognized channel, but
             # i really don't want to be bothered with asyncio exception handling
             # for that vanishingly improbable case.
             output[channels[message[0]]].extend(message[1:-1].decode('utf-8').split('\n'))

   ctx.load_verify_locations(c.ssl_ca_cert)
   if(c.cert_file and c.key_file):
     ctx.load_cert_chain(c.cert_file, c.key_file)
   uri = 'wss://%s%s' % (c.host.lstrip('https://'), path)

   asyncio.get_event_loop().run_until_complete(ExecCoroutine())

   return(output)
