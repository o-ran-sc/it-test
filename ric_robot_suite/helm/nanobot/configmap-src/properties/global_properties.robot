{{- $ns := default "ricplt" .Values.ric.platform.namespace }}
{{- $release := default "r0" .Values.ric.platform.releaseName }}
{{- $domain := default "cluster.local" .Values.ric.cluster.domain }}
{{- $hostPrefix := printf "service-%s" $ns }}
{{- $hostSuffix := printf "%s.svc.%s" $ns $domain }}
{{- $appmgrHost := printf "%s-appmgr-http.%s" $hostPrefix $hostSuffix }}
{{- $e2mgrHost := printf "%s-e2mgr-http.%s" $hostPrefix $hostSuffix }}
{{- $rtmgrHost := printf "%s-rtmgr-rmr.%s" $hostPrefix $hostSuffix }}
{{- $dbaasHost := printf "%s-dbaas-tcp.%s" $hostPrefix $hostSuffix }}
{{- $a1MediatorHost :=  printf "%s-a1mediator-http.%s" $hostPrefix $hostSuffix }}

*** Settings ***
Documentation        store all properties that can change or are used in multiple places here
...                    format is all caps with underscores between words and prepended with GLOBAL
...                   make sure you prepend them with GLOBAL so that other files can easily see it is from this file.


*** Variables ***
${GLOBAL_APPLICATION_ID}            {{- printf "nanobot-%s" $release | indent 4}}
${GLOBAL_BUILD_NUMBER}              {{- default "0" .Values.ric.platform.build | indent 4 }}
#
${GLOBAL_APPMGR_SERVER_PROTOCOL}    {{- default "http" .Values.ric.platform.components.appmgr.protocol | indent 4 }}
${GLOBAL_INJECTED_APPMGR_IP_ADDR}   {{- default $appmgrHost .Values.ric.platform.components.appmgr.address | indent 4 }}
${GLOBAL_APPMGR_SERVER_PORT}        {{- default "8080" .Values.ric.platform.components.appmgr.port  | indent 4 }}
${GLOBAL_INJECTED_APPMGR_USER}      {{- .Values.ric.platform.components.appmgr.user | indent 4 }}
${GLOBAL_INJECTED_APPMGR_PASSWORD}  {{- .Values.ric.platform.components.appmgr.password | indent 4 }}
#
${GLOBAL_E2MGR_SERVER_PROTOCOL}     {{- default "http" .Values.ric.platform.components.e2mgr.protocol | indent 4 }}
${GLOBAL_INJECTED_E2MGR_IP_ADDR}    {{- default $e2mgrHost .Values.ric.platform.components.e2mgr.address | indent 4 }}
${GLOBAL_E2MGR_SERVER_PORT}         {{- default "3800" .Values.ric.platform.components.e2mgr.port  | indent 4 }}
${GLOBAL_INJECTED_E2MGR_USER}       {{- .Values.ric.platform.components.e2mgr.user | indent 4 }}
${GLOBAL_INJECTED_E2MGR_PASSWORD}   {{- .Values.ric.platform.components.e2mgr.password | indent 4 }}
#
${GLOBAL_RTMGR_SERVER_PROTOCOL}     {{- default "http" .Values.ric.platform.components.rtmgr.protocol | indent 4 }}
${GLOBAL_INJECTED_RTMGR_IP_ADDR}    {{- default $rtmgrHost .Values.ric.platform.components.rtmgr.address | indent 4 }}
${GLOBAL_RTMGR_SERVER_PORT}         {{- default "5656" .Values.ric.platform.components.rtmgr.port  | indent 4 }}
${GLOBAL_INJECTED_RTMGR_USER}       {{- .Values.ric.platform.components.rtmgr.user | indent 4 }}
${GLOBAL_INJECTED_RTMGR_PASSWORD}   {{- .Values.ric.platform.components.rtmgr.password | indent 4 }}
#
${GLOBAL_INJECTED_DBAAS_IP_ADDR}    {{- default $dbaasHost .Values.ric.platform.components.dbaas.address | indent 4 }}
${GLOBAL_DBAAS_SERVER_PORT}         {{- default "6379" .Values.ric.platform.components.dbaas.port  | indent 4 }}
