
Ansible
===

ansible all -m ping --ask-pass
ansible ys-test -m ping --ask-pass

-m 
yum
user
git
service
commad
shell
script
copy
file

ansible-playbook playbooks/demo.yml
ansible-playbook playbooks/demo.yml -f 10


    when: ansible_os_family == "RedHat" and ansible_distribution_version|int <=5

一般所需的目录层有：(视情况可变化)
  vars     变量层
  tasks    任务层
  handlers 触发条件
  files    文件
  template 模板


