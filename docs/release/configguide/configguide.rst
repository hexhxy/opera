.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Yingjun Li (HUAWEI) and Harry Huang (HUAWEI)

Config Guide
------------------

Add OpenStack Admin Openrc file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Add the admin openrc file of your local openstack into opera/conf
directory with the name of admin-openrc.sh.

Config open-o.yml
~~~~~~~~~~~~~~~~~

Set openo_version to specify Open-O version.

Set openo_ip to specify an external ip to access Open-O services.
(leave the value unset will use local server's external ip)

Set ports in openo_docker_net to specify Open-O's exposed service
ports.

Set enable_sdno to specify if use Open-O 's sdno services.
(set this value false will not launch Open-O sdno dockers and reduce
deploy duration)

Set vnf_type to specify the vnf type need to be deployed.
(currently only support clearwater deployment, leave this unset will
not deploy any vnf)
