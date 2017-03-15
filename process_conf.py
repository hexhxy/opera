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


def generate_openo_conf(openo_config, scripts_dir):
    """generate opera/work/scripts_dir/open-o.conf"""
    with open(scripts_dir + "/open-o.conf", "w") as fd:
        for i in openo_config["openo_net"].keys():
            fd.write('{0}={1}\n'.format(i.upper(), openo_config["openo_net"][i]))

        for i in openo_config["openo_docker_net"]:
            fd.write('{0}={1}\n'.format(i.upper(), openo_config["openo_docker_net"][i]))

        fd.write('{0}={1}\n'.format('OPENO_VERSION', openo_config["openo_version"]))


def generate_app_conf(openo_config, app_config, scripts_dir):
    """generate opera/work/scripts_dir/application.conf"""
    with open(scripts_dir + "/application.conf", "w") as fd:
        for i in app_config["application"]:
            if i["name"] == openo_config["application"]:
                fd.write('{0}={1}\n'.format('APP_NAME', i["name"]))
                fd.write('{0}={1}\n'.format('APP_NS_PKG', i["ns_pkg"]))
                fd.write('{0}={1}'.format('APP_VNF_PKG', i["vnf_pkg"]))
            break


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("parameter wrong%d %s" % (len(sys.argv), sys.argv))
        sys.exit(1)

    _, openo_file, app_file = sys.argv

    if not os.path.exists(openo_file):
        print("network.yml doesn't exit")
        sys.exit(1)

    if not os.path.exists(app_file):
        print("application.yml doesn't exit")
        sys.exit(1)

    openo_config = load_file(openo_file)
    if not openo_config:
        print('format error in %s' % openo_file)
        sys.exit(1)

    app_config = load_file(app_file)
    if not app_config:
        print('format error in %s' % app_file)
        sys.exit(1)

    opera_dir = os.getenv('OPERA_DIR')
    scripts_dir = os.path.join(opera_dir, 'work/scripts')
    if not os.path.exists(scripts_dir):
        print("dir opera/work/scripts doesn't exit")
        sys.exit(1)

    generate_openo_conf(openo_config, scripts_dir)
    generate_app_conf(openo_config, app_config, scripts_dir)
