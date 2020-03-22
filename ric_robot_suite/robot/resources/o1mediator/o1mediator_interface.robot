*** Settings ***
Library  XML
Library  NcclientLibrary

*** Variables ***
${XAppNS}                 urn:o-ran:ric:xapp-desc:1.0
${NetconfNS}              urn:ietf:params:xml:ns:netconf:base:1.0
${baseXML}                <ric xmlns="${XAppNS}"></ric>

*** Keywords ***
Establish O1 Session
  [Arguments]  ${user}
  ...          ${password}
  ...          ${session}
  ...          ${host}=service-ricplt-o1mediator-tcp-netconf.ricplt
  ...          ${port}=830
  ...          ${hostkey_verify}=${False}
  ...          ${key}=/dev/null
  ${success} =  Connect      host=${host}
  ...             port=${port}
  ...             username=${user}
  ...             password=${password}
  ...             key_filename=${key}
  ...             look_for_keys=False
  ...             alias=${session}
  [Return]      ${success}

Retrieve O1 Running Configuration
  [Arguments]     ${session}
  ${config} =     Get Config   ${session}  running
  [Return]        ${config}

Deploy An XApp Using O1
  ${xappCreateXML} =  Generate XApp Deployment XML  ueec-xapp  0.0.1
  Log To Console  ${xappCreateXML}

*** Keywords ***
Generate XApp Deployment XML
  [Arguments]  ${name}    ${version}
  ${XML} =     Parse XML  <ric xmlns="${XAppNS}"></ric>
  Add Element  ${XML}
  ...                     <xapps xmlns="${XAppNS}"></xapps>
  Add Element  ${XML}     <xapp xmlns:xc="${NetconfNS}" xc:operation="create"></xapp>
  ...                     xpath=xapps
  Add Element  ${XML}
  ...                     <name>${name}</name>
  ...                     xpath=xapps/xapp
  Add Element  ${XML}     <release-name>xapp-${name}</release-name>
  ...                     xpath=xapps/xapp
  Add Element  ${XML}     <version>${version}</version>
  ...                     xpath=xapps/xapp
  Add Element  ${XML}     <namespace>${GLOBAL_XAPP_NAMESPACE}</namespace>
  ...                     xpath=xapps/xapp
  ${XMLText} =            Element To String  ${XML}
  [Return]                ${XMLText}

