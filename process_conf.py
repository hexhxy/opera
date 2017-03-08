import os
import yaml
import sys
import subprocess
import traceback


def load_file(file):
    with open(file) as fd:
        try:
            return yaml.load(fd)
        except:
            traceback.print_exc()
            return None


def generate_vm_conf(vm_config, scripts_dir):
    """generate opera/work/scripts_dir/openo-vm.conf"""
    print vm_config["openo"]["cpu"]
    with open(scripts_dir + "/openo-vm.conf", "w") as fd:
        fd.write("OPENO_TAG=" + str(vm_config["openo"]["tag"]) + "\n")
        fd.write("OPENO_VIRT_CPUS=" + str(vm_config["openo"]["cpu"]) + "\n")
        fd.write("OPENO_VIRT_MEM=" + str(vm_config["openo"]["memory"]) + "\n")
        fd.write("OPENO_VIRT_DISK=" + str(vm_config["openo"]["disk"]) + "\n")
        fd.write("OPENO_VM_NET=" + vm_config["openo"]["vnet"] + "\n")


def generate_net_conf(net_config, scripts_dir):
    """generate opera/work/scripts_dir/network.conf"""
    with open(scripts_dir + "/network.conf", "w") as fd:
        for i in net_config["openo_net"].keys():
            fd.write(i.upper() + "=" + net_config["openo_net"][i])
            fd.write("\n")

        for key in net_config["openo_docker_net"]:
            fd.write('{0}={1}'.format(key.upper(), net_config["openo_docker_net"][key]))
            fd.write("\n")

        for i in net_config["juju_net"].keys():
            fd.write(i.upper() + "=" + net_config["juju_net"][i])
            fd.write("\n")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("parameter wrong%d %s" % (len(sys.argv), sys.argv))
        sys.exit(1)

    _, net_file = sys.argv

    if not os.path.exists(net_file):
        print("network.yml doesn't exit")
        sys.exit(1)

    net_config = load_file(net_file)
    if not net_config:
        print('format error in %s' % net_file)
        sys.exit(1)

    opera_dir = os.getenv('OPERA_DIR')
    scripts_dir = os.path.join(opera_dir, 'work/scripts')
    if not os.path.exists(scripts_dir):
        print("dir opera/work/scripts doesn't exit")
        sys.exit(1)

    generate_net_conf(net_config, scripts_dir)
