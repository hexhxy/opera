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


def generate_net_conf(openo_config, scripts_dir):
    """generate opera/work/scripts_dir/open-o.conf"""
    with open(scripts_dir + "/open-o.conf", "w") as fd:
        for i in openo_config["openo_net"].keys():
            fd.write('{0}={1}'.format(i.upper(), openo_config["openo_net"][i]))
            fd.write("\n")

        for i in openo_config["openo_docker_net"]:
            fd.write('{0}={1}'.format(i.upper(), openo_config["openo_docker_net"][i]))
            fd.write("\n")

        fd.write('{0}={1}'.format('APPLICATION', openo_config["application"]))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("parameter wrong%d %s" % (len(sys.argv), sys.argv))
        sys.exit(1)

    _, openo_file = sys.argv

    if not os.path.exists(openo_file):
        print("network.yml doesn't exit")
        sys.exit(1)

    openo_config = load_file(openo_file)
    if not openo_config:
        print('format error in %s' % openo_file)
        sys.exit(1)

    opera_dir = os.getenv('OPERA_DIR')
    scripts_dir = os.path.join(opera_dir, 'work/scripts')
    if not os.path.exists(scripts_dir):
        print("dir opera/work/scripts doesn't exit")
        sys.exit(1)

    generate_net_conf(openo_config, scripts_dir)
