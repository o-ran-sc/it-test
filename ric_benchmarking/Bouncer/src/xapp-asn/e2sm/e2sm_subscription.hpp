/*
# ==================================================================================
# Copyright (c) 2020 HCL Technologies Limited.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==================================================================================
*/


/* Classes to handle E2 service model based on e2sm-Bouncer-v001.asn */
#ifndef E2SM_
#define E2SM_


#include <sstream>
#include <e2sm_helpers.hpp>
#include <mdclog/mdclog.h>
#include <vector>

#include <E2SM-Bouncer-EventTriggerDefinition.h>
#include <E2SM-Bouncer-ActionDefinition.h>
#include <E2SM-Bouncer-EventTriggerDefinition-Format1.h>
#include <E2SM-Bouncer-ActionDefinition-Format1.h>
#include <B-TriggerNature.h>
#include <RANparameter-Item.h>

/* builder class for E2SM event trigger definition */

class e2sm_subscription {
public:
	e2sm_subscription(void);
  ~e2sm_subscription(void);

  bool set_fields(E2SM_Bouncer_EventTriggerDefinition_t *, e2sm_subscription_helper &);
  bool set_fields(E2SM_Bouncer_ActionDefinition_t *, e2sm_subscription_helper &);

  bool encode_event_trigger(unsigned char *, size_t *, e2sm_subscription_helper &);
  bool encode_action_defn(unsigned char*, size_t *, e2sm_subscription_helper &);


  std::string  get_error (void) const {return error_string ;};

private:

  E2SM_Bouncer_EventTriggerDefinition_t * event_trigger; // used for encoding
  E2SM_Bouncer_ActionDefinition_t* action_defn;
  E2SM_Bouncer_EventTriggerDefinition_Format1_t event_fmt1;
  E2SM_Bouncer_ActionDefinition_Format1_t actn_fmt1;
  RANparameter_Item_t *ran_param;


  size_t errbuf_len;
  char errbuf[128];
  std::string error_string;
};



#endif
