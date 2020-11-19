CXX:= g++ --std=c++14 -O2 -L/usr/local/lib
CC:= gcc -O2 -L/usr/local/lib

SRC:=./
B_SRC:=./
UTILSRC=./xapp-utils
MSGSRC:=./xapp-mgmt

ASNSRC:=../asn1c_defs
E2APSRC:=./xapp-asn/e2ap
E2SMSRC:=./xapp-asn/e2sm

####### Logging library and flags
CLOGFLAGS:= `pkg-config mdclog --cflags`
LOG_LIBS:= `pkg-config mdclog --libs`
CURL_LIBS:= `pkg-config libcurl --libs`
RNIB_LIBS:= -pthread /usr/local/include/rnib/rnibreader.a
######## Keep include dirs separate so we have transparency


BASEFLAGS=  -Wall -std=c++14 $(CLOGFLAGS) 
C_BASEFLAGS= -Wall $(CLOGFLAGS) -DASN_DISABLE_OER_SUPPORT

XAPPFLAGS= -I./
B_FLAGS= -I./
UTILFLAGS= -I$(UTILSRC)
MSGFLAGS= -I$(MSGSRC)

ASNFLAGS=-I$(ASNSRC) -DASN_DISABLE_OER_SUPPORT
E2APFLAGS = -I$(E2APSRC)
E2SMFLAGS = -I$(E2SMSRC)

########libs

LIBS= -lsdl -lrmr_si  -lpthread -lm $(LOG_LIBS) $(CURL_LIBS) $(RNIB_LIBS)
COV_FLAGS= -fprofile-arcs -ftest-coverage

#######
B_XAPP_SRC= b_xapp_main.cc
XAPP_SRC= xapp.cc
UTIL_SRC= $(wildcard $(UTILSRC)/*.cc)
MSG_SRC= $(wildcard $(MSGSRC)/*.cc)

E2AP_SRC= $(wildcard $(E2APSRC)/*.cc)
E2SM_SRC= $(wildcard $(E2SMSRC)/*.cc)
ASN1C_SRC= $(wildcard $(ASNSRC)/*.c)

##############Objects
UTIL_OBJ=${UTIL_SRC:.cc=.o}
XAPP_OBJ=${XAPP_SRC:.cc=.o}
B_XAPP_OBJ= ${B_XAPP_SRC:.cc=.o} 
MSG_OBJ= ${MSG_SRC:.cc=.o}

E2AP_OBJ = $(E2AP_SRC:.cc=.o)
E2SM_OBJ = $(E2SM_SRC:.cc=.o)
ASN1C_MODULES = $(ASN1C_SRC:.c=.o)

$(ASN1C_MODULES): export CFLAGS = $(C_BASEFLAGS) $(ASNFLAGS)
$(UTIL_OBJ):export CPPFLAGS=$(BASEFLAGS) $(UTILFLAGS) $(E2APFLAGS) $(E2SMFLAGS) $(ASNFLAGS) $(MSGFLAGS)

$(MSG_OBJ):export CPPFLAGS=$(BASEFLAGS) $(MSGFLAGS) $(ASNFLAGS) $(E2APFLAGS) $(E2SMFLAGS)
$(E2AP_OBJ): export CPPFLAGS = $(BASEFLAGS) $(ASNFLAGS) $(E2APFLAGS)
$(E2SM_OBJ): export CPPFLAGS = $(BASEFLAGS) $(ASNFLAGS) $(E2SMFLAGS)
$(XAPP_OBJ): export CPPFLAGS = $(BASEFLAGS) $(XAPPFLAGS) $(UTILFLAGS) $(MSGFLAGS) $(E2APFLAGS) $(E2SMFLAGS) $(ASNFLAGS)

$(B_XAPP_OBJ):export CPPFLAGS=$(BASEFLAGS) $(B_FLAGS) $(XAPPFLAGS) $(UTILFLAGS) $(MSGFLAGS) $(E2APFLAGS) $(E2SMFLAGS) $(ASNFLAGS)

OBJ= $(B_XAPP_OBJ) $(UTIL_OBJ) $(MSG_OBJ)  $(ASN1C_MODULES) $(E2AP_OBJ) $(E2SM_OBJ) $(XAPP_OBJ)

print-%  : ; @echo $* = $($*)

b_xapp_main: $(OBJ)
	$(CXX) -o $@  $(OBJ) $(LIBS) $(RNIBFLAGS) $(CPPFLAGS) $(CLOGFLAGS) 

install: b_xapp_main
	install  -D b_xapp_main  /usr/local/bin/b_xapp_main

clean:
	-rm *.o $(ASNSRC)/*.o $(E2APSRC)/*.o $(UTILSRC)/*.o $(E2SMSRC)/*.o  $(MSGSRC)/*.o $(SRC)/*.o b_xapp_main 
