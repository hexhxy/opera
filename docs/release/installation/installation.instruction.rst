.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Yingjun Li (HUAWEI) and Harry Huang (HUAWEI)

Opera Installation Instructions
===============================

This document providing guidelines on how to deploy a working Open-O
environment using opera project.

The audience of this document is assumed to have good knowledge in
OpenStack and Linux.


Preconditions
-------------

There are some preconditions before starting the Opera deployment


A functional OpenStack environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

OpenStack should be deployed before opera deploy.

Getting the deployment scripts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Retrieve the repository of Opera using the following command:

- git clone https://gerrit.opnfv.org/gerrit/opera


Machine requirements
--------------------

1.     Ubuntu OS (Pre-installed).

2.     Root access.

3.     Minimum 1 NIC (internet access)

4.     CPU cores: 32

5.     64 GB free memory

6.     100G free disk


Deploy Instruction
------------------

After opera deployment, Open-O dockers will be launched on local
server as orchestrator and juju vm will be launched on OpenStack
as VNFM.

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

Run opera_launch.sh
~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    ./opera_launch.sh

