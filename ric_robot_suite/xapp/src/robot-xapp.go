/*
==================================================================================
  Copyright (c) 2019 AT&T Intellectual Property.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
==================================================================================
*/
package main

import "gerrit.o-ran-sc.org/r/ric-plt/xapp-frame/pkg/xapp"
import "encoding/json"
import "strconv"
       

type robotPolicy struct {
  Message string  `json:"message"`
}

type A1Policy struct {
  Operation  string       `json:"operation"`
  Type       int          `json:"policy_type_id"`
  Instance   string       `json:"policy_instance_id"`
  Payload    robotPolicy  `json:"payload"`
}

type A1Response struct {
  Type       int          `json:"policy_type_id"`
  Instance   string       `json:"policy_instance_id"`
  Handler    string       `json:"handler_id"`
  Status     string       `json:"status"`
}

type robotXApp struct {
  metrics map[string]xapp.Counter  
}

func sdlKey(t int, i string) (key string) {
  return strconv.Itoa(t) +"|"+ i
}

func (r robotXApp) SendA1Response (t int, i string, handler string, status string)  {
  /* A1_POLICY_RESP, _ := xapp.Rmr.GetRicMessageId("A1_POLICY_RESP") */
  A1_POLICY_RESP := 20011
  msg, _ := json.Marshal(A1Response {
                                      Type: t,
                                      Instance: i,
                                      Handler: handler,
                                      Status: status,
                                      })
                                         
   xapp.Logger.Debug("Outgoing A1 Response %s (length %d)", string(msg), len(msg))
   /* fixme: check response for errors */
   xapp.Rmr.SendMsg(&xapp.RMRParams {
                                    Mtype: A1_POLICY_RESP,
                                    Payload: msg,
                                    PayloadLen: len(msg),
                                    Xid: "",
                                    SubId: t,
                                   })
   r.metrics["MessagesSent"].Inc()
}

func (r robotXApp) CreatePolicy(t int, i string, policy robotPolicy)  {
  k := sdlKey(t, i)
  err := xapp.Sdl.Store(k, policy.Message)
  if err == nil {
    xapp.Logger.Debug("Created instance %s of policy %d", i, t)
    r.metrics["PolicyCreates"].Inc()
    r.metrics["dbStores"].Inc()
    r.SendA1Response(t, i, "robot", "OK")
  } else {
    xapp.Logger.Error("Failed to create DB record for instance %s of policy %d: %v", i, t, err)
    r.metrics["dbStoreFailures"].Inc()
    r.SendA1Response(t, i, "robot", "ERROR")
  }
}

func (r robotXApp) DeletePolicy(t int, i string)  {
  k := sdlKey(t, i)
  
  policies, _  := xapp.Sdl.Read(k)
  existingPolicy, _ := policies[k]

  if existingPolicy != nil {
    err := xapp.Sdl.Delete([]string{k})
    if err == nil {
      xapp.Logger.Debug("Deleted instance %s of policy %d, old value: %s", i, t, existingPolicy)
      r.metrics["PolicyDeletes"].Inc()
      r.metrics["dbDeletes"].Inc()
      r.SendA1Response(t, i, "robot", "DELETED")
    } else {
      xapp.Logger.Error("Failed to delete DB record for instance %s of policy %d: %v", i, t, err)
      r.metrics["dbDeleteFailures"].Inc()
      r.SendA1Response(t, i, "robot", "ERROR")
    }
  } else {
    xapp.Logger.Error("Attempt to delete nonexistent instance %s of policy %d", i, t)
    r.metrics["NonexistentPolicyDeletes"].Inc()
    r.SendA1Response(t, i, "robot", "ERROR")
  }  
}

func (r robotXApp) Consume(msg *xapp.RMRParams) (err error) {
  /* this is returning 0.  will investigate and fix someday. */
  /* A1_POLICY_REQ, _ := xapp.Rmr.GetRicMessageId("A1_POLICY_REQ") */
  A1_POLICY_REQ := 20010

  xapp.Logger.Debug("Message received - type=%d, Src=%s (%s), payload=%s",
                    msg.Mtype, xapp.Rmr.GetRicMessageName(msg.Mtype), msg.Src, string(msg.Payload))

  /* this is bogus right now, but we'll eventually support more than one message
     also, xapps really should handle messages in a separate goroutine, but there's 
     no real need in this one as we're not latency bound */
  if msg.Mtype == A1_POLICY_REQ {
    var a1Msg A1Policy
    err := json.Unmarshal(msg.Payload, &a1Msg)
    
    xapp.Logger.Debug("... Policy request - err=%v|op=%s|type=%d|instance=%s",
                      err, a1Msg.Operation, a1Msg.Type, a1Msg.Instance)
    switch a1Msg.Operation {
    case "CREATE":
      go r.CreatePolicy(a1Msg.Type, a1Msg.Instance, a1Msg.Payload)
    case "DELETE":
      go r.DeletePolicy(a1Msg.Type, a1Msg.Instance)
    }
  }
  return nil
}

func main() {
  counters := []xapp.CounterOpts {
    { Name: "PolicyCreates", Help: "A1 policies created" },
    { Name: "DuplicatePolicyCreates",
      Help: "A1 CREATE requests received for existing policy instances" },
    { Name: "PolicyUpdates", Help: "A1 policies updateded" },
    { Name: "NonexistentPolicyUpdates",
      Help: "A1 UPDATE requests received for nonexistent policy instances" },
    { Name: "PolicyDeletes", Help: "A1 policies deleted" },
    { Name: "NonexistentPolicyDeletes",
      Help: "A1 DELETE requests received for nonexistent policy instances" },
    { Name: "dbStores",
      Help: "SDL store requests" },
    { Name: "dbStoreFailures",
      Help: "SDL store request failures" },
    { Name: "dbDeletes",
      Help: "SDL delete requests" },
    { Name: "dbDeleteFailures",
      Help: "SDL delete request failures" },
    { Name: "MessagesReceived",
      Help: "Total RMR messages received" },
    { Name: "MessagesSent",
      Help: "Total RMR messages sent" },
  }
  xapp.Run(robotXApp{ metrics: xapp.Metric.RegisterCounterGroup(counters, "robotXApp")})
}
