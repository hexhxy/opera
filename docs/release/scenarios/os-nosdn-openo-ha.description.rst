.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Yingjun Li (HUAWEI) and Harry Huang (HUAWEI)

os-nosdn-openo-ha Description
===========================

Introduction
------------

Since OPNFV board expanded its scope to include NFV MANO last year,
several upstream open source projects have been created to develop
MANO solutions. Each solution has demonstrated its unique value in
specific area. Open-Orchestrator (OPEN-O) project is one of such
communities. Opera seeks to develop requirements for OPEN-O MANO
support in the OPNFV reference platform, with the plan to eventually
integrate OPEN-O in OPNFV as a non-exclusive upstream MANO. The
project will definitely benefit not only OPNFV and Open-O, but can
be referenced by other MANO integration as well. In particular, this
project is basically use case driven. Based on that, it will focus
on the requirement of interfaces/data models for integration among
various components and OPNFV platform. The requirement is designed
to support integration among Open-O as NFVO with Juju as VNFM and
OpenStack as VIM.

Currently OPNFV has already included upstream OpenStack as VIM, and
Juju and Tacker have been being considered as gVNFM by different OPNFV
projects. OPEN-O as NFVO part of MANO will interact with OpenStack and
Juju. The key items required for the integration can be described as
follows.

Scenario Components and Composition
-----------------------------------

This Scenario will deploy Open-O on jump host as orchestrator and deploy
juju in an OpenStack VM as VNFM. All Open-O service can be access through
openo_ip specified in network config file.

Scenario Usage Overview
-----------------------

This scenario has an orchestrator field to specify which orchestrator to
be used.

COMPASS installer configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The os-nosdn-openo-ha scenario in Compass4NFV has an orchestrator field.
Set orchestrator type to Open-O to install Open-O after Compass4NFV finishs
NFVI deployment and Open-O version can also be assigned in key version.
With orchestrator setting to Open-O, Compass4NFV will git clone Opera
project to perform a combined deployment. Set key vnf to clearwater if you
want to launch clearwater after Open-O launched.

os-nosdn-openo-ha scenario needs to be deployed along with Open-O included
network config file. Compass4NFV has network_openo.yml to config network for
Opera.

The Open-O related info in both scenario and network config will be synchronized
into Opera after its repository being cloned.

References
----------

For more information on the OPNFV Danube release, please visit
http://www.opnfv.org/danube
