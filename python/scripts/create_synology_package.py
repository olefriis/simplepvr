#!/usr/bin/python
# -*- coding: utf-8 -*-

from shutil import copytree, make_archive
import os
import sys
import shutil


def main(argv=None):
    syno_package_dir = "syno_package"
    build_dir = os.path.abspath(os.path.join(os.path.curdir, syno_package_dir))
    os.mkdir(build_dir)

    create_info(build_dir)
    copy_scripts(build_dir)
    download_src(build_dir)
    download_requirements(build_dir)
    package_dist(build_dir)
    print "Done"


def create_info(target_dir):
    info_file = target_dir+"/INFO"
    with open(info_file, 'w') as f:
        f.write('package="SimplePVR"' + os.linesep)
        f.write('version="0.0.1"' + os.linesep)
        f.write('maintainer="Flemming Jønsson <flemming@joensson.org>"' + os.linesep)
        f.write('description="SimplePVR"' + os.linesep)
        f.write('arch="noarch"' + os.linesep)


def copy_scripts(target_dir):
    scripts_dir_name = "scripts"

    templates_dir = "templates/" + scripts_dir_name

    copytree(templates_dir, target_dir+"/"+scripts_dir_name)

def download_src(target_dir):
    from subprocess import PIPE, call, check_call, check_output

    src_download_dir = os.path.join(target_dir, "source")
    shutil.rmtree(src_download_dir, ignore_errors=True)
    os.makedirs(src_download_dir)
    current_dir = os.curdir
    os.chdir(src_download_dir)
    check_call("git clone git://github.com/olefriis/simplepvr.git", shell=True)
    os.chdir(current_dir)


def download_requirements(target_dir):
    from subprocess import PIPE, call, check_call, check_output
    from psutil import Popen
    from datetime import datetime
    import time
    dependencies_dir = os.path.join(target_dir, "dependencies")
    os.makedirs(dependencies_dir)
    requirements_file = os.path.join("simplepvr", "python", "simplepvr", "requirements.txt" )
    command = "pip install --download-cache={} --ignore-installed --no-install  -r {}".format(dependencies_dir, requirements_file)

    src_dep_build_dir = os.path.join(target_dir, "source", "build")
    if not os.path.exists(src_dep_build_dir):
        os.makedirs(src_dep_build_dir)

    print "Executing '{}'".format(command)
    start = datetime.now()
    #proc = Popen(command, close_fds=True, shell=True, stdout=sys.stdout, stderr=sys.stderr)
    check_output(command, close_fds=True, shell=True)
    print "pip executed in ",(datetime.now() - start).total_seconds(), " seconds"

#    while proc.is_running():
#        print "Running for ", (datetime.now() - start).total_seconds(), " seconds"
#        time.sleep(1)

    for f in os.listdir(src_dep_build_dir):
        if os.path.isfile(f):
            print "Deleting file: ", f
        if os.path.isdir(f):
            print "Dir: ", f
#            os.unlink(f)

def package_dist(target_dir):
    print "TODO - implement packaging of src + build-deps"
    dist_dir = os.path.join(target_dir, "tar_this")
    #shutil.rmtree(dist_dir, ignore_errors=True)
    source_dir = os.path.join(target_dir, "source", "simplepvr", "python")
    shutil.copytree(source_dir, dist_dir)

    raise Exception("TODO - implement packaging of src + build-deps")

if __name__ == "__main__":
    sys.exit(main())
