*** Settings ***
Documentation        store all properties that can change or are used in multiple places here
...                  format is all caps with underscores between words and prepended with GLOBAL
...                  make sure you prepend them with GLOBAL so that other files can easily see it
...                  is from this file.


*** Variables ***
${GLOBAL_RICPLT_NAMESPACE}                ricplt
&{GLOBAL_RICPLT_COMPONENTS}               a1mediator=deployment-ricplt-a1mediator
...                                       appmgr=deployment-ricplt-appmgr
...                                       e2mgr=deployment-ricplt-e2mgr
...                                       e2term=deployment-ricplt-e2term
...                                       rtmgr=deployment-ricplt-rtmgr
${GLOBAL_APPLICATION_ID}                  ric-robot
${GLOBAL_BUILD_NUMBER}                    0
#
${GLOBAL_RIC_PRIVATE_KEY}                 ${EXECDIR}/robot/assets/keys/ric_dev.pvt
#
${GLOBAL_SELENIUM_BROWSER}                chrome
${GLOBAL_SELENIUM_BROWSER_CAPABILITIES}   Create Dictionary
${GLOBAL_SELENIUM_DELAY}                  0
${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}  5
${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}   15

