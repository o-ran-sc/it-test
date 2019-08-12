# ======================================================================
#         Copyright (c) 2019 Nokia
#         Copyright (c) 2018-2019 AT&T Intellectual Property.

#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at

#        http://www.apache.org/licenses/LICENSE-2.0

#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#    implied. See the License for the specific language governing
#    permissions andlimitations under the License.
# ======================================================================

CC= gcc
CFLAGS= -Wunused-variable
LIBS= -lrmr_nng  -lnng -lpthread -lm

WG_G= src/ric_generator.c
WG_R= src/ric_receiver.c

all: ric_generator ric_receiver

ric_generator: $(WG_G)
	$(CC) -o $@  $^ $(LIBS) $(CFLAGS) $(CPPFLAGS)

ric_receiver: $(WG_R)
	$(CC) -o $@  $^ $(LIBS) $(CFLAGS) $(CPPFLAGS)

clean:
	rm ric_generator ric_receiver
