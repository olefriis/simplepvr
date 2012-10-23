# -*- coding: <utf-8> -*-
#!/usr/bin/env python

__author__ = 'frj'

import os
from setuptools import setup, find_packages

# Utility function to read the README file.
# Used for the long_description.  It's nice, because now 1) we have a top level
# README file and 2) it's easier to type in the README file than to put a raw
# string in below ...
def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

def readlines(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).readlines()

setup(
    name = "SimplePVR",
    version = "0.0.1",
    author = "Flemming Joensson",
    author_email = "flemming@joensson.org",
    description = ("A Python implementation of the SimplePVR ReST backend for "
                   "controlling a HDHomerun tuner. The frontend is developed "
                   "in AngularJS by Ole Friis"),
    license = "BSD",
    keywords = "rest hdhomerun pvr",
    url = "http://packages.python.org/an_example_pypi_project",
    packages=find_packages(),
    #scripts = ['pvr_server.py', 'read_xmltv.py'],
    install_requires = [ readlines('requirements.txt') ],
    test_suite = 'simple_pvr.test.functional.SimplePVRTestCase',
    long_description=read('README.md'),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Topic :: Utilities",
        "License :: OSI Approved :: BSD License",
        ],
    )