---
- name: Shell module example
  hosts: 127.0.0.1
  tasks:
  
  - name: Check system information
    shell:
      "curl -v http://TARGET-IP:32080/appmgr/ric/v1/health/ready 2>&1"
    register: os_info
    
  - debug:
      msg: "{{os_info.stdout_lines}}"
