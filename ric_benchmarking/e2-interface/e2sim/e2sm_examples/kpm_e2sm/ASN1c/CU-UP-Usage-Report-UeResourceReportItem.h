/*
 * Generated by asn1c-0.9.29 (http://lionet.info/asn1c)
 * From ASN.1 module "E2SM-KPM-IEs"
 * 	found in "/home/rshacham/e2sm-kpm-v01.02.asn"
 * 	`asn1c -fcompound-names`
 */

#ifndef	_CU_UP_Usage_Report_UeResourceReportItem_H_
#define	_CU_UP_Usage_Report_UeResourceReportItem_H_


#include <asn_application.h>

/* Including external dependencies */
#include "C-RNTI.h"
#include <INTEGER.h>
#include <constr_SEQUENCE.h>

#ifdef __cplusplus
extern "C" {
#endif

/* CU-UP-Usage-Report-UeResourceReportItem */
typedef struct CU_UP_Usage_Report_UeResourceReportItem {
	C_RNTI_t	 c_RNTI;
	INTEGER_t	*pDCPBytesDL;	/* OPTIONAL */
	INTEGER_t	*pDCPBytesUL;	/* OPTIONAL */
	/*
	 * This type is extensible,
	 * possible extensions are below.
	 */
	
	/* Context for parsing across buffer boundaries */
	asn_struct_ctx_t _asn_ctx;
} CU_UP_Usage_Report_UeResourceReportItem_t;

/* Implementation */
extern asn_TYPE_descriptor_t asn_DEF_CU_UP_Usage_Report_UeResourceReportItem;
extern asn_SEQUENCE_specifics_t asn_SPC_CU_UP_Usage_Report_UeResourceReportItem_specs_1;
extern asn_TYPE_member_t asn_MBR_CU_UP_Usage_Report_UeResourceReportItem_1[3];

#ifdef __cplusplus
}
#endif

#endif	/* _CU_UP_Usage_Report_UeResourceReportItem_H_ */
#include <asn_internal.h>
