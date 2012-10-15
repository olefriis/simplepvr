#!/usr/bin/python
# -*- coding: utf-8 -*-

from shutil import copytree, make_archive
import os
import sys


def main(argv=None):
    syno_package_dir = "syno_package"
    os.mkdir(syno_package_dir)

    create_info(syno_package_dir)
    move_scripts(syno_package_dir)
    archive_src(os.path.join(os.pardir, 'tst/simplepvr/python'), syno_package_dir)
    fix_pip_download_names()
    print "Done"


def create_info(target_dir):
    info_file = target_dir+"/INFO"
    with open(info_file, 'w') as f:
        f.write('package="SimplePVR"' + os.linesep)
        f.write('version="0.0.1"' + os.linesep)
        f.write('maintainer="Flemming Jønsson <flemming@joensson.org>"' + os.linesep)
        f.write('description="SimplePVR"' + os.linesep)
        f.write('arch="noarch"' + os.linesep)


def move_scripts(target_dir):
    scripts_dir_name = "scripts"

    templates_dir = "templates/" + scripts_dir_name

    copytree(templates_dir, target_dir+"/"+scripts_dir_name)

def archive_src(src_dir, target_dir):
    print src_dir
    archive_name = os.path.join(target_dir, 'package')
    make_archive(archive_name, 'gztar', src_dir)
    os.rename(os.path.join(target_dir, 'package.tar.gz'), os.path.join(target_dir, 'package.tgz'))

def fix_pip_download_names():
    folder = os.path.join(os.pardir, 'tst')
    search_pattern = "%2F"
    suffix = ".tar.gz"
    files = os.listdir(folder)
    for f in files:
        print f

if __name__ == "__main__":
    sys.exit(main())
