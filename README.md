OPNFV OPEN-O Integration Source Codes

Code Structure:
opera/
├── ci
│   └── deploy.sh
├── conf
│   ├── admin-openrc.sh # compass openrc file
│   ├── juju.conf # juju config
│   ├── openo-docker.conf # open-o docker config
│   └── openo-vm.conf # open-o vm config
├── INFO
├── juju
│   ├── juju_launch.sh # launch juju vms
│   └── juju_setup.sh # juju prepare 
├── LICENSE
├── model
│   ├── bind.csar
│   ├── bono.csar
│   ├── ellis.csar
│   ├── homer.csar
│   ├── homestead.csar
│   ├── proxy_node.csar
│   ├── ralf.csar
│   ├── sprout.csar
│   └── vIMS_NS.csar
├── open-o
│   ├── openo_docker.sh # launch open-o docker inside open-o vm
│   └── openo_vm.sh # launch open-o vm
├── opera_launch.sh # opera deploy entrance
├── prepare.sh # prepare work for opera
├── README.md
└── util
    ├── isolinux.cfg # kickstart open-o vm
    ├── ks.cfg # kickstart open-o vm
    ├── libvirt.xml # define open-o vm
    └── log.sh # different log print

