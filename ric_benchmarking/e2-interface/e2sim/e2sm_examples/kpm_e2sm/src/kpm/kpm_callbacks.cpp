/*****************************************************************************
#                                                                            *
# Copyright 2020 AT&T Intellectual Property                                  *
#                                                                            *
# Copyright (c) 2020 HCL Technologies Limited.                               *
#                                                                            *
# Licensed under the Apache License, Version 2.0 (the "License");            *
# you may not use this file except in compliance with the License.           *
# You may obtain a copy of the License at                                    *
#                                                                            *
#      http://www.apache.org/licenses/LICENSE-2.0                            *
#                                                                            *
# Unless required by applicable law or agreed to in writing, software        *
# distributed under the License is distributed on an "AS IS" BASIS,          *
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
# See the License for the specific language governing permissions and        *
# limitations under the License.                                             *
#                                                                            *
******************************************************************************/

#include <iostream>
#include <fstream>
#include <vector>
#include <unistd.h>
#include <curses.h> 
#include<deque>
extern "C" {
  #include "OCUCP-PF-Container.h"
  #include "OCTET_STRING.h"
  #include "asn_application.h"
  #include "E2SM-KPM-IndicationMessage.h"
  #include "FQIPERSlicesPerPlmnListItem.h"
  #include "E2SM-KPM-RANfunction-Description.h"
  #include "E2SM-KPM-IndicationHeader-Format1.h"
  #include "E2SM-KPM-IndicationHeader.h"
  #include "Timestamp.h"
  #include "E2AP-PDU.h"
  #include "RICsubscriptionRequest.h"
  #include "RICsubscriptionResponse.h"
  #include "RICactionType.h"
  #include "ProtocolIE-Field.h"
  #include "ProtocolIE-SingleContainer.h"
  #include "InitiatingMessage.h"
}

#include "kpm_callbacks.hpp"
#include "encode_kpm.hpp"

#include "encode_e2apv1.hpp"

#include <nlohmann/json.hpp>
#include <thread>
#include <pthread.h>
using json = nlohmann::json;

using namespace std;
class E2Sim;


E2Sim e2sim;

struct args {

    int args1;
    //char **args2;
    char** args2;
    int plmnId;

};

unordered_map<long, E2AP_PDU_t *> glob_map;//will store the object of E2AP_PDU_t created while handdling the  subscription request in e2ap_handle_sctp_data() //key is ricInstanceID

unordered_map<int,timeval> Time;//Global var in kpm_callbacks.cpp

//int main(int argc, char* argv[]) {

void *initparam(void *input){	
  fprintf(stderr, "Starting KPM processor sim\n");

  //struct args *value1 = (struct args *)malloc(sizeof(struct args));
  //fprintf(stderr,"ip address at initparam :%s port:%s\n",(char *)input->args2[1],(char *)input->args2[2]);
  //struct args *value1 = (struct args *)input;
 // value1 = (struct args *)input;
  struct args *value1 = ( args *) input;
  //fprintf(stderr,"ip address at initparam :%s port:%s\n",value1->args2[1],value1->args2[2]);


  asn_codec_ctx_t *opt_cod;

  E2SM_KPM_RANfunction_Description_t *ranfunc_desc =
    (E2SM_KPM_RANfunction_Description_t*)calloc(1,sizeof(E2SM_KPM_RANfunction_Description_t));
  encode_kpm_function_description(ranfunc_desc);

  uint8_t e2smbuffer[8192];
  size_t e2smbuffer_size = 8192;

  asn_enc_rval_t er =
    asn_encode_to_buffer(opt_cod,
			 ATS_ALIGNED_BASIC_PER,
			 &asn_DEF_E2SM_KPM_RANfunction_Description,
			 ranfunc_desc, e2smbuffer, e2smbuffer_size);
  
  fprintf(stderr, "er encded is %d\n", er.encoded);
  fprintf(stderr, "after encoding message\n");
  fprintf(stderr, "here is encoded message %s\n", e2smbuffer);

  uint8_t *ranfuncdesc = (uint8_t*)calloc(1,er.encoded);
  memcpy(ranfuncdesc, e2smbuffer, er.encoded);

  printf("this is the char array %s\n", (char*)ranfuncdesc);

  OCTET_STRING_t *ranfunc_ostr = (OCTET_STRING_t*)calloc(1,sizeof(OCTET_STRING_t));
  ranfunc_ostr->buf = (uint8_t*)calloc(1,er.encoded);
  ranfunc_ostr->size = er.encoded;
  memcpy(ranfunc_ostr->buf,e2smbuffer,er.encoded);

  printf("!!!lenth of ranfuncdesc is %d\n", strlen((char*)ranfuncdesc));
/*  printf("value of this index is %d\n", ranfuncdesc[0]);
  printf("value of this index is %d\n", ranfuncdesc[1]);
  printf("value of this index is %d\n", ranfuncdesc[2]);
  printf("value of this index is %d\n", ranfuncdesc[3]);
  printf("value of this index is %d\n", ranfuncdesc[4]);
  printf("value of this index is %d\n", ranfuncdesc[5]);
  printf("value of this index is %d\n", ranfuncdesc[6]);
  printf("value of this index is %d\n", ranfuncdesc[10]);
  printf("value of this index is %d\n", ranfuncdesc[15]);
  printf("value of this index is %d\n", ranfuncdesc[100]);
  printf("value of this index is %d\n", ranfuncdesc[101]);
  */
  e2sim.register_e2sm(0,ranfunc_ostr);
  e2sim.register_subscription_callback(0,&callback_kpm_subscription_request);
  e2sim.register_e2sm(1,ranfunc_ostr);
  
  // will register the callback_kpm_subscription_delete_request in SubscriptionCallback corresponding to RANfunctionID=1
  e2sim.register_subscription_callback(1,&callback_kpm_subscription_delete_request);
  fprintf(stderr,"ip address at run loop call:%s port:%s\n",value1->args2[1],value1->args2[2]);
  e2sim.run_loop(value1->args1,value1->args2,value1->plmnId);//(argc, argv);

}


int main(int argc, char  **argv) {
	
        struct args *value = (struct args *)malloc(sizeof(struct args));
        value->args1  = argc;
	value->args2  = argv;
//	printf("Enter number of e2sim\n");
//	int num_of_e2sim = getch();
        value->plmnId = 1;
	//int plmnid = 1;

	int num_of_e2sim;
	if (value->args2[3] != NULL)
	{
		num_of_e2sim = atoi(value->args2[3]);//500;
		fprintf(stderr,"number of e2sim : %d\n", num_of_e2sim);
	} 

	else
	{
		num_of_e2sim = 1;
	}
	//int num_of_e2sim = atoi(value->args2[3]);//500;

	//options_t read_input_options(int argc, char* argv[]);

	fprintf(stderr,"value of thread id is %d\n", num_of_e2sim);

	fprintf(stderr,"argc : %d ,ip address:%s, port:%s\n", value->args1,value->args2[1], value->args2[2]); 

	pthread_t threads[10000];
	int retvalue;
  	int i;
        for( i = 0; i < num_of_e2sim; i++ ) {
             
	     //struct args *value = (struct args *)malloc(sizeof(struct args));	
	     
	      
             //struct args *value = (struct args *)malloc(sizeof(struct args));
             //value->args1  = argc;
             //value->args2  = argv;
	     //value->plmnId = plmnid;

		
	     fprintf(stderr,"\n****************************************************************************************************\n");	
	     //fprintf(stderr,"argc: %d, argv ip address is:%s,argv  port:%s\n",argc, argv[1],argv[2]);

	     fprintf(stderr,"value of thread id is %d\n", i);
	     fprintf(stderr,"value of plmn   id is %d\n", value->plmnId);
	     fprintf(stderr,"ip address is:%s, port:%s\n", value->args2[1],value->args2[2]);
             retvalue = pthread_create(&threads[i], NULL, initparam, (void *)value);
	     sleep(2);
	     value->plmnId++;
	  //   plmnid++;
      
             if (retvalue) {
                 
		 fprintf(stderr,"Error:unable to create  thread, %d\n", retvalue);
                 exit(-1);
             }
	     
     	}
	//fprintf(stderr,"main function of e2sim ended 1\n");
   pthread_exit(NULL);
   //fprintf(stderr,"main function of e2sim ended 2\n");
}

/*
void run_report_loop(long requestorId, long instanceId, long ranFunctionId, long actionId) {

}
*/

void run_report_loop(long requestorId, long instanceId, long ranFunctionId, long actionId,int client_fd) {

  //Process simulation file

  ifstream simfile;
  string line;

  long seqNum = 1;

  int  maxInd = 1;//500; //1000 no of indication to  send
  
  simfile.open("simulation.txt", ios::in);

  //  cout << "step1" << endl;

  std::ifstream ue_stream("/playpen/src/ueMeasReport.txt");
  std::ifstream cell_stream("/playpen/src/cellMeasReport.txt");

  json all_ues_json;

  ue_stream  >> all_ues_json;

  json all_cells_json;

  cell_stream >> all_cells_json;

  asn_codec_ctx_t *opt_cod;

  //  cout << "UE RF Measurements" << endl;
  //  cout << "******************" << endl;

  int numMeasReports = (all_ues_json["/ueMeasReport/ueMeasReportList"_json_pointer]).size();

  for (int i = 0; i < numMeasReports; i++) {
    int nextCellId;
    int nextRsrp;
    int nextRsrq;
    int nextRssinr;
    //    cout << "UE number " + i << endl;
    //    cout << "**********" << endl;
    json::json_pointer p1(std::string("/ueMeasReport/ueMeasReportList/") + std::to_string(i) +"/nrCellIdentity");
    nextCellId = all_ues_json[p1].get<int>();
    //    cout << "Serving Cell " << nextCellId << endl;
    
    json::json_pointer p2(std::string("/ueMeasReport/ueMeasReportList/") + std::to_string(i) +"/servingCellRfReport/rsrp");
    nextRsrp = all_ues_json[p2].get<int>();
    //    cout << "  RSRP " << nextRsrp << endl;
    json::json_pointer p3(std::string("/ueMeasReport/ueMeasReportList/") + std::to_string(i) +"/servingCellRfReport/rsrq");
    nextRsrq = all_ues_json[p3].get<int>();
    //    cout << "  RSRQ " << nextRsrq << endl;
    json::json_pointer p4(std::string("/ueMeasReport/ueMeasReportList/") + std::to_string(i) +"/servingCellRfReport/rssinr");
    nextRssinr = all_ues_json[p4].get<int>();
    //    cout << "  RSSINR " << nextRssinr << endl;

    json::json_pointer p5(std::string("/ueMeasReport/ueMeasReportList/") + std::to_string(i) +"/neighbourCellList");

    int numNeighborCells = (all_ues_json[p5]).size();


    //REPORT Message 3 -- Encode and send OCUCP user-level report
    
    E2SM_KPM_IndicationMessage_t *ind_msg3 =
      (E2SM_KPM_IndicationMessage_t*)calloc(1,sizeof(E2SM_KPM_IndicationMessage_t));
    E2AP_PDU *pdu3 = (E2AP_PDU*)calloc(1,sizeof(E2AP_PDU));
    
    uint8_t *crnti_buf = (uint8_t*)calloc(1,2);

    if (nextCellId == 0) {
      uint8_t *buf2 = (uint8_t*)"12";
      memcpy(crnti_buf, buf2, 2);
    } else if (nextCellId == 1) {
      uint8_t *buf2 = (uint8_t*)"22";
      memcpy(crnti_buf, buf2, 2);
    }

    std::string serving_str = "{\"rsrp\": " + std::to_string(nextRsrp) + ", \"rsrq\": " +
      std::to_string(nextRsrq) + ", \"rssinr\": " + std::to_string(nextRssinr) + "}";
    const uint8_t *serving_buf = reinterpret_cast<const uint8_t*>(serving_str.c_str());
        
    std::string neighbor_str = "[";

    int nextNbCell;
    int nextNbRsrp;
    int nextNbRsrq;
    int nextNbRssinr;

    for (int j = 0; j < numNeighborCells; j++) {
      json::json_pointer p8(std::string("/ueMeasReport/ueMeasReportList/") + std::to_string(i) +"/neighbourCellList/" + std::to_string(j) + "/nbCellIdentity");
      nextNbCell = all_ues_json[p8].get<int>();
      //cout << "Neighbor Cell " << all_ues_json[p8] << endl;
      json::json_pointer p9(std::string("/ueMeasReport/ueMeasReportList/") + std::to_string(i)
			    +"/neighbourCellList/" + std::to_string(j) + "/nbCellRfReport/rsrp");
      nextNbRsrp = all_ues_json[p9].get<int>();
      //cout << "  RSRP " << nextNbRsrp << endl;

      json::json_pointer p10(std::string("/ueMeasReport/ueMeasReportList/") + std::to_string(i)
			    +"/neighbourCellList/" + std::to_string(j) + "/nbCellRfReport/rsrq");
      nextNbRsrq = all_ues_json[p10].get<int>();
      //cout << "  RSRQ " << nextNbRsrq << endl;

      json::json_pointer p11(std::string("/ueMeasReport/ueMeasReportList/") + std::to_string(i)
			     +"/neighbourCellList/" + std::to_string(j) + "/nbCellRfReport/rssinr");
      nextNbRssinr = all_ues_json[p11].get<int>();
      //cout << "  RSSINR " << nextNbRssinr << endl;

      if (j != 0) {
	neighbor_str += ",";

      }

      neighbor_str += "{\"CID\" : \"" + std::to_string(nextNbCell) + "\", \"Cell-RF\" : \"{\"rsrp\": " + std::to_string(nextNbRsrp) +
	", \"rsrq\": " + std::to_string(nextNbRsrq) + ", \"rssinr\": " + std::to_string(nextNbRssinr) + "}}";
      
    }

    neighbor_str += "]";
    
    const uint8_t *neighbor_buf = reinterpret_cast<const uint8_t*>(neighbor_str.c_str());
    
    //    printf("Neighbor string\n%s", neighbor_buf);

    uint8_t *plmnid_buf = (uint8_t*)"747";
    uint8_t *nrcellid_buf = (uint8_t*)"12340";

    /*
    encode_kpm_report_rancontainer_cucp_parameterized(ind_msg3, plmnid_buf, nrcellid_buf, crnti_buf, serving_buf, neighbor_buf);
    
    uint8_t e2smbuffer3[8192];
    size_t e2smbuffer_size3 = 8192;

    
    asn_enc_rval_t er3 = asn_encode_to_buffer(opt_cod,
					      ATS_ALIGNED_BASIC_PER,
					      &asn_DEF_E2SM_KPM_IndicationMessage,
					      ind_msg3, e2smbuffer3, e2smbuffer_size3);
    
    fprintf(stderr, "er encded is %d\n", er3.encoded);
    fprintf(stderr, "after encoding message\n");
    uint8_t *e2smheader_buf3 = (uint8_t*)"";
    
    generate_e2apv1_indication_request_parameterized(pdu3, requestorId,
						     instanceId, ranFunctionId,
						     actionId, seqNum, e2smheader_buf3, 0, e2smbuffer3, er3.encoded);
    
						     e2sim.encode_and_send_sctp_data(pdu3);
    */
    
    seqNum++;
        
  }


  //  cout << "Cell Measurements" << endl;
  //  cout << "******************" << endl;

  int numCellMeasReports = (all_cells_json["/cellMeasReport/cellMeasReportList"_json_pointer]).size();

  uint8_t *sst_buf = (uint8_t*)"1";
  uint8_t *sd_buf = (uint8_t*)"100";
  uint8_t *plmnid_buf = (uint8_t*)"747";
  
  for (int i = 0; i < numCellMeasReports; i++) {

    int nextCellId;
    int nextPdcpBytesDL;
    int nextPdcpBytesUL;
    int nextPRBBytesDL;
    int nextPRBBytesUL;

    json::json_pointer p1(std::string("/cellMeasReport/cellMeasReportList/") + std::to_string(i) +"/nrCellIdentity");
    nextCellId = all_cells_json[p1].get<int>();
    //    cout << std::string("Cell number ") << nextCellId << endl;
    
    //    cout << "**********" << endl;
    
    json::json_pointer p2(std::string("/cellMeasReport/cellMeasReportList/") + std::to_string(i) +"/pdcpByteMeasReport/pdcpBytesDl");
    nextPdcpBytesDL = all_cells_json[p2].get<int>();
    //    cout << std::string("  PDCP Bytes DL ") << nextPdcpBytesDL << endl;

    json::json_pointer p3(std::string("/cellMeasReport/cellMeasReportList/") + std::to_string(i) +"/pdcpByteMeasReport/pdcpBytesUl");
    nextPdcpBytesUL = all_cells_json[p3].get<int>();    
    //    cout << std::string("  PDCP Bytes UL ") << nextPdcpBytesUL << endl;

    uint8_t *buf = (uint8_t*)"GNBCUUP5";
    
    int bytes_dl = nextPdcpBytesDL;

    int bytes_ul = nextPdcpBytesUL;

    //    int bytes_dl = 3905;
    //    int bytes_ul = 1609321;
    
    E2SM_KPM_IndicationMessage_t *ind_msg2 =
      (E2SM_KPM_IndicationMessage_t*)calloc(1,sizeof(E2SM_KPM_IndicationMessage_t));
    E2AP_PDU *pdu2 = (E2AP_PDU*)calloc(1,sizeof(E2AP_PDU));
    
    encode_kpm_report_style5_parameterized(ind_msg2 , buf, bytes_dl, bytes_ul, sst_buf, sd_buf, plmnid_buf);
    
    uint8_t e2smbuffer2[8192];
    size_t e2smbuffer_size2 = 8192;
    
    asn_enc_rval_t er2 = asn_encode_to_buffer(opt_cod,
					      ATS_ALIGNED_BASIC_PER,
					      &asn_DEF_E2SM_KPM_IndicationMessage,
					      ind_msg2, e2smbuffer2, e2smbuffer_size2);

    //fprintf(stderr, "er encded is %d\n", er2.encoded);
    //fprintf(stderr, "after encoding message\n");

    E2SM_KPM_IndicationHeader_t *ihead =
      (E2SM_KPM_IndicationHeader_t*)calloc(1,sizeof(E2SM_KPM_IndicationHeader_t));

    
    E2SM_KPM_IndicationHeader_Format1_t* ind_header =
      (E2SM_KPM_IndicationHeader_Format1_t*)calloc(1,sizeof(E2SM_KPM_IndicationHeader_Format1_t));

    OCTET_STRING_t *plmnid = (OCTET_STRING_t*)calloc(1,sizeof(OCTET_STRING_t));
    plmnid->buf = (uint8_t*)calloc(3,1);
    plmnid->size = 3;
    memcpy(plmnid->buf, plmnid_buf, plmnid->size);

    long fqival = 9;
    long qcival = 9;

    OCTET_STRING_t *sst = (OCTET_STRING_t*)calloc(1, sizeof(OCTET_STRING_t));
    sst->size = 6;
    sst->buf = (uint8_t*)calloc(1,6);
    memcpy(sst->buf,sst_buf,sst->size);
    

    OCTET_STRING_t *sds = (OCTET_STRING_t*)calloc(1, sizeof(OCTET_STRING_t));
    sds->size = 3;
    sds->buf = (uint8_t*)calloc(1,3);
    memcpy(sds->buf, sd_buf, sds->size);
    
    
    SNSSAI_t *snssai = (SNSSAI_t*)calloc(1, sizeof(SNSSAI_t));
    ASN_STRUCT_RESET(asn_DEF_SNSSAI,snssai);
    snssai->sST.buf = (uint8_t*)calloc(1,1);
    snssai->sST.size = 1;
    memcpy(snssai->sST.buf, sst_buf, 1);
    snssai->sD = (OCTET_STRING_t*)calloc(1, sizeof(OCTET_STRING_t));
    snssai->sD->buf = (uint8_t*)calloc(1,3);
    snssai->sD->size = 3;
    memcpy(snssai->sD->buf, sd_buf, 3);

        
    ind_header->pLMN_Identity = plmnid;
    ind_header->fiveQI = &fqival;

    BIT_STRING_t *nrcellid = (BIT_STRING_t*)calloc(1, sizeof(BIT_STRING_t));;
    nrcellid->buf = (uint8_t*)calloc(1,5);
    nrcellid->size = 5;
    nrcellid->buf[0] = 0x22;
    nrcellid->buf[1] = 0x5B;
    nrcellid->buf[2] = 0xD6;
    nrcellid->buf[3] = 0x00;
    nrcellid->buf[4] = 0x70;
    
    nrcellid->bits_unused = 4;

    BIT_STRING_t *gnb_bstring = (BIT_STRING_t*)calloc(1, sizeof(BIT_STRING_t));;
    gnb_bstring->buf = (uint8_t*)calloc(1,4);
    gnb_bstring->size = 4;
    gnb_bstring->buf[0] = 0xB5;
    gnb_bstring->buf[1] = 0xC6;
    gnb_bstring->buf[2] = 0x77;
    gnb_bstring->buf[3] = 0x88;
    
    gnb_bstring->bits_unused = 3;

    INTEGER_t *cuup_id = (INTEGER_t*)calloc(1, sizeof(INTEGER_t));
    uint8_t buffer[1];
    buffer[0] = 20000;
    cuup_id->buf = (uint8_t*)calloc(1,1);
    memcpy(cuup_id->buf, buffer, 1);
    cuup_id->size = 1;

    ind_header->id_GlobalKPMnode_ID = (GlobalKPMnode_ID*)calloc(1,sizeof(GlobalKPMnode_ID));
    ind_header->id_GlobalKPMnode_ID->present = GlobalKPMnode_ID_PR_gNB;
    ind_header->id_GlobalKPMnode_ID->choice.gNB.global_gNB_ID.gnb_id.present = GNB_ID_Choice_PR_gnb_ID;
    ind_header->id_GlobalKPMnode_ID->choice.gNB.global_gNB_ID.gnb_id.choice.gnb_ID = *gnb_bstring;
    ind_header->id_GlobalKPMnode_ID->choice.gNB.global_gNB_ID.plmn_id = *plmnid;
    ind_header->id_GlobalKPMnode_ID->choice.gNB.gNB_CU_UP_ID = cuup_id;

    ind_header->nRCGI = (NRCGI*)calloc(1,sizeof(NRCGI));
    ind_header->nRCGI->pLMN_Identity = *plmnid;
    ind_header->nRCGI->nRCellIdentity = *nrcellid;

    ind_header->sliceID = snssai;
    ind_header->qci = &qcival;
    //    ind_header->message_Type = ;
    //    ind_header->gNB_DU_ID = ;

    
    uint8_t *buf5 = (uint8_t*)"GNBCUUP5";
    OCTET_STRING_t *cuupname = (OCTET_STRING_t*)calloc(1, sizeof(OCTET_STRING_t));
    cuupname->size = 8;
    cuupname->buf = (uint8_t*)calloc(1,8);
    memcpy(cuupname->buf, buf5, cuupname->size);    

    
    ind_header->gNB_Name = (GNB_Name*)calloc(1,sizeof(GNB_Name));
    ind_header->gNB_Name->present = GNB_Name_PR_gNB_CU_UP_Name;
    ind_header->gNB_Name->choice.gNB_CU_UP_Name = *cuupname;


    ind_header->global_GNB_ID = (GlobalgNB_ID*)calloc(1,sizeof(GlobalgNB_ID));
    ind_header->global_GNB_ID->plmn_id = *plmnid;
    ind_header->global_GNB_ID->gnb_id.present = GNB_ID_Choice_PR_gnb_ID;
    ind_header->global_GNB_ID->gnb_id.choice.gnb_ID = *gnb_bstring;
    

    ihead->present = E2SM_KPM_IndicationHeader_PR_indicationHeader_Format1;
    ihead->choice.indicationHeader_Format1 = *ind_header;

    //printf("IndicationHeader - now printing xer\n");
    //xer_fprint(stderr, &asn_DEF_E2SM_KPM_IndicationHeader, ihead);
    //printf("IndicationHeader - done printing xer\n");      

    uint8_t e2sm_header_buffer[8192];
    size_t e2sm_header_buffer_size = 8192;
    
    asn_enc_rval_t er4 = asn_encode_to_buffer(opt_cod,
					      ATS_ALIGNED_BASIC_PER,
					      &asn_DEF_E2SM_KPM_IndicationHeader,
					      ihead, e2sm_header_buffer, e2sm_header_buffer_size);    
    
    uint8_t *e2smheader_buf2 = (uint8_t*)"";

    int seqNum0 = 1;

    if (i == 0) {
    
      sleep(10); //added sleep before sending indication because bouncer xapp need to some time to receive subscription response properly 

      for(int ind=0; ind<maxInd; ind++) {

            fprintf(stderr,"\nSending RIC Indication with seqnum = %d max_num_of_Ind = %d \n", seqNum0,maxInd);

            encoding::generate_e2apv1_indication_request_parameterized(pdu2, requestorId,
								 instanceId, ranFunctionId,
								 actionId, seqNum0, e2sm_header_buffer, er4.encoded, e2smbuffer2, er2.encoded);
      
            e2sim.encode_and_send_sctp_data(pdu2,client_fd);

	    seqNum0++;
      }	    
    }

    seqNum++;

    

    json::json_pointer p4(std::string("/cellMeasReport/cellMeasReportList/") + std::to_string(i) +"/prbMeasReport/availPrbDl");
    nextPRBBytesDL = all_cells_json[p4].get<int>();    
    //    cout << std::string("  PRB Bytes DL ") << all_cells_json[p4] << endl;

    json::json_pointer p5(std::string("/cellMeasReport/cellMeasReportList/") + std::to_string(i) +"/prbMeasReport/availPrbUl");
    nextPRBBytesUL = all_cells_json[p5].get<int>();
    //    cout << std::string("  PRB Bytes UL ") << all_cells_json[p5] << endl;


    //REPORT Message 1 -- Encode and send ODU cell-level report
    
    E2SM_KPM_IndicationMessage_t *ind_msg1 =
      (E2SM_KPM_IndicationMessage_t*)calloc(1,sizeof(E2SM_KPM_IndicationMessage_t));
    E2AP_PDU *pdu = (E2AP_PDU*)calloc(1,sizeof(E2AP_PDU));
    
    long fiveqi = 7;

    uint8_t *nrcellid_buf = (uint8_t*)"12340";
    long dl_prbs = nextPRBBytesDL;
    long ul_prbs = nextPRBBytesUL;

    /*
    encode_kpm_report_style1_parameterized(ind_msg1, fiveqi, dl_prbs, ul_prbs, sst_buf, sd_buf, plmnid_buf, nrcellid_buf, &dl_prbs, &ul_prbs);
    
    uint8_t e2smbuffer[8192];
    size_t e2smbuffer_size = 8192;
    
    asn_enc_rval_t er = asn_encode_to_buffer(opt_cod,
					     ATS_ALIGNED_BASIC_PER,
					     &asn_DEF_E2SM_KPM_IndicationMessage,
					     ind_msg1, e2smbuffer, e2smbuffer_size);
    
    fprintf(stderr, "er encded is %d\n", er.encoded);
    fprintf(stderr, "after encoding message\n");
    uint8_t *e2smheader_buf = (uint8_t*)"";
    
    uint8_t *cpid_buf = (uint8_t*)"CPID";
    
    fprintf(stderr, "About to encode Indication\n");
    generate_e2apv1_indication_request_parameterized(pdu, requestorId,
						     instanceId, ranFunctionId,
						     actionId, seqNum, e2smheader_buf, 0, e2smbuffer, er.encoded);
    
						     e2sim.encode_and_send_sctp_data(pdu);
    */
    seqNum++;
    
  }



  /*
  if (simfile.is_open()) {

    while (getline(simfile, line)) {
      cout << line << "\n";

      //REPORT Message 1 -- Encode and send ODU cell-level report

      E2SM_KPM_IndicationMessage_t *ind_msg1 =
	(E2SM_KPM_IndicationMessage_t*)calloc(1,sizeof(E2SM_KPM_IndicationMessage_t));
      E2AP_PDU *pdu = (E2AP_PDU*)calloc(1,sizeof(E2AP_PDU));

      long fiveqi = 7;
      uint8_t *sst_buf = (uint8_t*)"1";
      uint8_t *sd_buf = (uint8_t*)"100";
      uint8_t *plmnid_buf = (uint8_t*)"747";
      uint8_t *nrcellid_buf = (uint8_t*)"12340";
      long dl_prbs = 100;
      long ul_prbs = 50; 
     
      encode_kpm_report_style1_parameterized(ind_msg1, fiveqi, dl_prbs, ul_prbs, sst_buf, sd_buf, plmnid_buf, nrcellid_buf, &dl_prbs, &ul_prbs);

      uint8_t e2smbuffer[8192];
      size_t e2smbuffer_size = 8192;
      asn_codec_ctx_t *opt_cod;

      asn_enc_rval_t er = asn_encode_to_buffer(opt_cod,
					       ATS_ALIGNED_BASIC_PER,
					       &asn_DEF_E2SM_KPM_IndicationMessage,
					       ind_msg1, e2smbuffer, e2smbuffer_size);
      
      fprintf(stderr, "er encded is %d\n", er.encoded);
      fprintf(stderr, "after encoding message\n");
      uint8_t *e2smheader_buf = (uint8_t*)"header";

      uint8_t *cpid_buf = (uint8_t*)"CPID";

      fprintf(stderr, "About to encode Indication\n");
      generate_e2apv1_indication_request_parameterized(pdu, requestorId,
						       instanceId, ranFunctionId,
						       actionId, seqNum, e2smheader_buf, 6, e2smbuffer, er.encoded);

      encode_and_send_sctp_data(pdu, socket_fd);
      
      seqNum++;

      //REPORT Message 2 -- Encode and send OCUUP cell-level report

      uint8_t *buf = (uint8_t*)"GNBCUUP5";

      int bytes_dl = 40000;
      int bytes_ul = 50000;

      E2SM_KPM_IndicationMessage_t *ind_msg2 =
	(E2SM_KPM_IndicationMessage_t*)calloc(1,sizeof(E2SM_KPM_IndicationMessage_t));
      E2AP_PDU *pdu2 = (E2AP_PDU*)calloc(1,sizeof(E2AP_PDU));
      
      encode_kpm_report_style5_parameterized(ind_msg2 , buf, bytes_dl, bytes_ul, sst_buf, sd_buf, plmnid_buf);

      uint8_t e2smbuffer2[8192];
      size_t e2smbuffer_size2 = 8192;


      asn_enc_rval_t er2 = asn_encode_to_buffer(opt_cod,
					       ATS_ALIGNED_BASIC_PER,
					       &asn_DEF_E2SM_KPM_IndicationMessage,
					       ind_msg2, e2smbuffer2, e2smbuffer_size2);
      
      fprintf(stderr, "er encded is %d\n", er2.encoded);
      fprintf(stderr, "after encoding message\n");
      uint8_t *e2smheader_buf2 = (uint8_t*)"header";

      generate_e2apv1_indication_request_parameterized(pdu2, requestorId,
						       instanceId, ranFunctionId,
						       actionId, seqNum, e2smheader_buf2, 6, e2smbuffer2, er2.encoded);

      encode_and_send_sctp_data(pdu2, socket_fd);
      
      seqNum++;

      //REPORT Message 3 -- Encode and send OCUCP user-level report

      E2SM_KPM_IndicationMessage_t *ind_msg3 =
	(E2SM_KPM_IndicationMessage_t*)calloc(1,sizeof(E2SM_KPM_IndicationMessage_t));
      E2AP_PDU *pdu3 = (E2AP_PDU*)calloc(1,sizeof(E2AP_PDU));

      uint8_t *crnti_buf = (uint8_t*)"12";
      //      uint8_t *serving_buf = (uint8_t*)"RSRP10";
      //uint8_t *neighbor_buf = (uint8_t*)"-10,-15";
      int rsrpServ = 10;
      int rsrqServ = 0;
      int rssinrServ = 0;

      std::string serving_str = "{\"rsrp\": " + std::to_string(rsrpServ) + ", \"rsrq\": " +
	std::to_string(rsrqServ) + ", \"rssinr\": " + std::to_string(rssinrServ) + "}";
      const uint8_t *serving_buf = reinterpret_cast<const uint8_t*>(serving_str.c_str());


      neighbor_cell_entry n_entries[3];
      n_entries[0] = {"123", 10, 0, 0};
      n_entries[1] = {"456", 10, 0, 0};
      n_entries[2] = {"789", 10, 0, 0};

      std::string neighbor_str = "[";

      for (int i=0; i < sizeof(n_entries)/sizeof(n_entries[0]); i++) {

	if (i != 0) {
	  neighbor_str += ",";
	}
	neighbor_str += "{\"CID\" : \"" + std::string(n_entries[i].cellid) + "\", \"Cell-RF\" : \"{\"rsrp\": " + std::to_string(n_entries[i].rsrp) +
	  ", \"rsrq\": " + std::to_string(n_entries[i].rsrq) + ", \"rssinr\": " + std::to_string(n_entries[i].rsrp) + "}}";
      }

      neighbor_str += "]";

      const uint8_t *neighbor_buf = reinterpret_cast<const uint8_t*>(neighbor_str.c_str());

      printf("Neighbor string\n%s", neighbor_buf);

      encode_kpm_report_rancontainer_cucp_parameterized(ind_msg3, plmnid_buf, nrcellid_buf, crnti_buf, serving_buf, neighbor_buf);
      
      uint8_t e2smbuffer3[8192];
      size_t e2smbuffer_size3 = 8192;

      asn_enc_rval_t er3 = asn_encode_to_buffer(opt_cod,
						ATS_ALIGNED_BASIC_PER,
						&asn_DEF_E2SM_KPM_IndicationMessage,
						ind_msg3, e2smbuffer3, e2smbuffer_size3);
      
      fprintf(stderr, "er encded is %d\n", er3.encoded);
      fprintf(stderr, "after encoding message\n");
      uint8_t *e2smheader_buf3 = (uint8_t*)"header";

      generate_e2apv1_indication_request_parameterized(pdu3, requestorId,
						       instanceId, ranFunctionId,
						       actionId, seqNum, e2smheader_buf3, 6, e2smbuffer3, er3.encoded);

      encode_and_send_sctp_data(pdu3, socket_fd);
            
      seqNum++;
      
      //Encode and send OCUUP user-level report


      
      //Encode and send ODU user-level report

      

      
    }

    simfile.close();

  }
  */

}
/*
//Now this function will accept the argument as Reference to pointer . 
//In order to store the actual address of E2AP_PDU_t object in glob_map created while handling the subscription request in e2ap_handle_sctp_data()
*/
void callback_kpm_subscription_request(E2AP_PDU_t *&sub_req_pdu,int client_fd) {

  fprintf(stderr, "Calling callback_kpm_subscription_request\n");

  //Record RIC Request ID
  //Go through RIC action to be Setup List
  //Find first entry with REPORT action Type
  //Record ricActionID
  //Encode subscription response

  RICsubscriptionRequest_t orig_req =
    sub_req_pdu->choice.initiatingMessage->value.choice.RICsubscriptionRequest;
  
  RICsubscriptionResponse_IEs_t *ricreqid =
    (RICsubscriptionResponse_IEs_t*)calloc(1, sizeof(RICsubscriptionResponse_IEs_t));
					   
  int count = orig_req.protocolIEs.list.count;
  int size = orig_req.protocolIEs.list.size;
  
  RICsubscriptionRequest_IEs_t **ies = (RICsubscriptionRequest_IEs_t**)orig_req.protocolIEs.list.array;

  fprintf(stderr, "count%d\n", count);
  fprintf(stderr, "size%d\n", size);

  RICsubscriptionRequest_IEs__value_PR pres;

  long reqRequestorId;
  long reqInstanceId;
  long reqActionId;

  std::vector<long> actionIdsAccept;
  std::vector<long> actionIdsReject;

  for (int i=0; i < count; i++) {
    RICsubscriptionRequest_IEs_t *next_ie = ies[i];
    pres = next_ie->value.present;
    
    fprintf(stderr, "The next present value %d\n", pres);

    switch(pres) {
	    //will now also add the sub_req_pdu in glob_map corresponding to ricInstanceID
    case RICsubscriptionRequest_IEs__value_PR_RICrequestID:
      {
	fprintf(stderr,"in case request id\n");	
	RICrequestID_t reqId = next_ie->value.choice.RICrequestID;
	long requestorId = reqId.ricRequestorID;
	long instanceId = reqId.ricInstanceID;
	fprintf(stderr, "requestorId %d\n", requestorId);
	fprintf(stderr, "instanceId %d\n", instanceId);
	  fprintf(stderr, "adding E2AP_PDU object in global map having ricinstance id= %d\n",instanceId);
            glob_map[instanceId]=sub_req_pdu;//adding in map
             fprintf(stderr, "added succesfully\n");
	reqRequestorId = requestorId;
	reqInstanceId = instanceId;

	break;
      }
    case RICsubscriptionRequest_IEs__value_PR_RANfunctionID:
      {
	fprintf(stderr,"in case ran func id\n");	
	break;
      }
    case RICsubscriptionRequest_IEs__value_PR_RICsubscriptionDetails:
      {
	fprintf(stderr,"in case subscription details\n");
	RICsubscriptionDetails_t subDetails = next_ie->value.choice.RICsubscriptionDetails;
	fprintf(stderr,"in case subscription details 1\n");	
	RICeventTriggerDefinition_t triggerDef = subDetails.ricEventTriggerDefinition;
	fprintf(stderr,"in case subscription details 2\n");	
	RICactions_ToBeSetup_List_t actionList = subDetails.ricAction_ToBeSetup_List;
	fprintf(stderr,"in case subscription details 3\n");
	//We are ignoring the trigger definition

	//We identify the first action whose type is REPORT
	//That is the only one accepted; all others are rejected
	
	int actionCount = actionList.list.count;
	fprintf(stderr, "action count%d\n", actionCount);

	auto **item_array = actionList.list.array;

	bool foundAction = false;

	for (int i=0; i < actionCount; i++) {

	  auto *next_item = item_array[i];
	  RICactionID_t actionId = ((RICaction_ToBeSetup_ItemIEs*)next_item)->value.choice.RICaction_ToBeSetup_Item.ricActionID;
	  RICactionType_t actionType = ((RICaction_ToBeSetup_ItemIEs*)next_item)->value.choice.RICaction_ToBeSetup_Item.ricActionType;

	  if (!foundAction && actionType == RICactionType_report) {
	    reqActionId = actionId;
	    actionIdsAccept.push_back(reqActionId);
	    printf("adding accept\n");
	    foundAction = true;
	  } else {
	    reqActionId = actionId;
	    printf("adding reject\n");
	    actionIdsReject.push_back(reqActionId);
	  }
	}
	
	break;
      }
    default:
      {
	fprintf(stderr,"in case default\n");	
	break;
      }      
    }
    
  }

  fprintf(stderr, "After Processing Subscription Request\n");

  fprintf(stderr, "requestorId %d\n", reqRequestorId);
  fprintf(stderr, "instanceId %d\n", reqInstanceId);


  for (int i=0; i < actionIdsAccept.size(); i++) {
    fprintf(stderr, "Action ID %d %ld\n", i, actionIdsAccept.at(i));
    
  }

  E2AP_PDU *e2ap_pdu = (E2AP_PDU*)calloc(1,sizeof(E2AP_PDU));

  long *accept_array = &actionIdsAccept[0];
  long *reject_array = &actionIdsReject[0];
  int accept_size = actionIdsAccept.size();
  int reject_size = actionIdsReject.size();

  encoding::generate_e2apv1_subscription_response_success(e2ap_pdu, accept_array, reject_array, accept_size, reject_size, reqRequestorId, reqInstanceId);

  e2sim.encode_and_send_sctp_data(e2ap_pdu,client_fd);

  //Start thread for sending REPORT messages

  //  std::thread loop_thread;

  long funcId = 1;

  run_report_loop(reqRequestorId, reqInstanceId, funcId, reqActionId,client_fd);

  //  loop_thread = std::thread(&run_report_loop);

}

void callback_kpm_subscription_delete_request(E2AP_PDU_t *&sub_del_req_pdu,int client_fd)
{

	fprintf(stderr, "Calling callback_kpm_subscription_delete_request\n");
  	//Record RIC Request ID
  	//Encode subscription delete response

  	RICsubscriptionDeleteRequest_t orig_req =
    		sub_del_req_pdu->choice.initiatingMessage->value.choice.RICsubscriptionDeleteRequest;

  	RICsubscriptionDeleteResponse_IEs_t *ricreqid =
    		(RICsubscriptionDeleteResponse_IEs_t*)calloc(1, sizeof(RICsubscriptionDeleteResponse_IEs_t));

  	int count = orig_req.protocolIEs.list.count;
  	int size = orig_req.protocolIEs.list.size;

  	RICsubscriptionDeleteRequest_IEs_t **ies = (RICsubscriptionDeleteRequest_IEs_t**)orig_req.protocolIEs.list.array;

  	fprintf(stderr, "count%d\n", count);
  	fprintf(stderr, "size%d\n", size);

  	RICsubscriptionDeleteRequest_IEs__value_PR pres;

  	long reqRequestorId;
  	long reqInstanceId;

  	for (int i=0; i < count; i++) 
	{
    		RICsubscriptionDeleteRequest_IEs_t *next_ie = ies[i];
    		pres = next_ie->value.present;

    		fprintf(stderr, "The next present value %d\n", pres);

    		switch(pres) 
		{
    			case RICsubscriptionDeleteRequest_IEs__value_PR_RICrequestID:
      			{
				fprintf(stderr,"in case request id\n");
				RICrequestID_t reqId = next_ie->value.choice.RICrequestID;
				long requestorId = reqId.ricRequestorID;
				long instanceId = reqId.ricInstanceID;
				fprintf(stderr, "requestorId %d\n", requestorId);
				fprintf(stderr, "instanceId %d\n", instanceId);
				reqRequestorId = requestorId;
				reqInstanceId = instanceId;

				break;
      			}
    			case RICsubscriptionDeleteRequest_IEs__value_PR_RANfunctionID:
      			{
				fprintf(stderr,"in case ran func id\n");
				break;
      			}
	
    			default:
      			{
				fprintf(stderr,"in case default\n");
				break;
      			}
    		}	

  	}



  	fprintf(stderr, "After Processing Subscription Delete Request\n");

	fprintf(stderr, "requestorId %d\n", reqRequestorId);
	fprintf(stderr, "instanceId %d\n", reqInstanceId);


	E2AP_PDU *e2ap_pdu = (E2AP_PDU*)calloc(1,sizeof(E2AP_PDU));
  	encoding::generate_e2apv1_subscription_delete_response_success(e2ap_pdu, reqRequestorId, reqInstanceId);
  	e2sim.encode_and_send_sctp_data(e2ap_pdu,client_fd);
	fprintf(stderr, "calling free_subscription_request_resources func after sending delete response\n");
	free_subscription_request_resources(sub_del_req_pdu, glob_map);


}


//will free the object of E2AP_PDU_t created while handdling the  subscription request in e2ap_handle_sctp_data()
void free_subscription_request_resources(E2AP_PDU_t *&pdu, std::unordered_map<long, E2AP_PDU_t *> &glob_map)
{

	RICsubscriptionDeleteRequest_t orig_req =
		pdu->choice.initiatingMessage->value.choice.RICsubscriptionDeleteRequest;


	RICsubscriptionDeleteRequest_IEs_t **ies = (RICsubscriptionDeleteRequest_IEs_t**)orig_req.protocolIEs.list.array;


	RICsubscriptionDeleteRequest_IEs_t *next_ie = ies[0];

	RICrequestID_t reqId = next_ie->value.choice.RICrequestID;

	long instanceId = reqId.ricInstanceID;
	fprintf(stderr, "instance id of  E2AP_PDU object  =%d \n",instanceId);
	E2AP_PDU_t* tmp=glob_map[instanceId];
	fprintf(stderr, "before erasing E2AP_PDU object from map, size of glob_map=%d \n",glob_map.size());
	glob_map.erase(instanceId);
	fprintf(stderr, "after erasing E2AP_PDU object  from map, size of glob_map=%d \n",glob_map.size());   
        if(!tmp)
   		 {  
	   		 fprintf(stderr,"E2AP_PDU object cannot freed, as ricinstance id =%d not present\n",instanceId);
       			 fprintf(stderr,"nullpointer\n");
   		 }
	if (tmp)
    		{  
	   		fprintf(stderr, "deleting E2AP_PDU object from memory having instance id = %d \n",instanceId); 
        		free(tmp);
			fprintf(stderr,"deleted succsessfully \n");
        
        		tmp=NULL;
   		 }	
}



