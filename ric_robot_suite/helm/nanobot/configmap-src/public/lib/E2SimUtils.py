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

from redis import Redis
import string
import random

class E2SimUtils(object):
 def __init__(self, dbaas, port=int(6379)):

  self._db = Redis(host=dbaas, port=port)

 def sdlKey(self, namespace, val):
  return "{%s},%s" % (namespace, val)

 def sdlKeyNamespace(self, k):
   return k.split(",")[0][1:-1]

 def sdlKeyVal(self, k):
   return k.split(",")[1]

 def e2RANKey(self, val):
  return self.sdlKey("e2Manager", "RAN:" + val)

 def e2RANKeyVal(self, k):
  return self.sdlKeyVal(k).split(':')[-1]

 def gNodeB(self, ranName="*"):
  # return one or (by default) all e2 records
  gnbs={}
  for k in self._db.keys(self.e2RANKey(ranName)):
   gnbs[self.e2RANKeyVal(k.decode('utf-8'))]=self._db.get(k)
  return gnbs

 def gNodeBDelete(self, ranName="*"):
  # delete one or (by default) all e2 records
  # returns the deleted records to avoid
  # buyer's remorse.
  gnbs = self.gNodeB(ranName)
  for k in gnbs:
   self._db.delete(self.e2RANKey(k))
  return gnbs

 def randomRANName(self, prefix=""):
  prefix = prefix + ''.join(random.choice(string.ascii_uppercase) for _ in range(4-(min(4, len(prefix)))))
  return prefix[0:4].upper() + ''.join(random.choice(string.digits) for _ in range(6))

 def TranslategNodeBID(self, prefix, plmn, bits):
  # given a gNodeB type prefix, a plmn (as a string, no spaces), and a bitstring
  # return a gNodeB ID
  plmn = ''.join(filter(lambda c: c in list(string.hexdigits), plmn))
  bits = ''.join(filter(lambda c: c in ['0', '1'], bits))
  mnc3 = (int(plmn[2:4],16) & 0xf0) >> 4
  if mnc3 == 15:
    return '%s:%d%d%d-0%d%d-%x' % \
     (prefix,\
      int(plmn[0:2],16) & 0xf, (int(plmn[0:2],16) & 0xf0) >> 4, int(plmn[2:4],16) & 0xf,\
      int(plmn[4:6],16) & 0x0f, (int(plmn[4:6],16) & 0xf0) >> 4, \
      int((bits + "0" * (len(bits)%4)),2))
  else:
    return '%s:%d%d%d-%d%d%d-%x' % \
     (prefix,\
      int(plmn[0:2],16) & 0xf, (int(plmn[0:2],16) & 0xf0) >> 4, int(plmn[2:4],16) & 0xf,\
      int(plmn[4:6],16) & 0x0f, (int(plmn[4:6],16) & 0xf0) >> 4, mnc3,\
      int((bits + "0" * (len(bits)%4)),2))
