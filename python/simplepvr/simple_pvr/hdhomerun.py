# -*- coding: <utf-8> -*-

#
# Encapsulates all the HDHomeRun-specific functionality. Do not initialize HDHomeRun objects yourself,
# but get the current instance through PvrInitializer.
#
import os
import subprocess
import sys
import codecs
import re

from threading import Timer
from subprocess import PIPE, call, check_call#, check_output # check_output is Python 2.7 only (Synology DSM 4 comes with 2.6)
from psutil import Popen

from .pvr_logger import logger

def call_os(cmd, check=True):
    logger().info(u"Executing '{0}'".format(cmd))
    if check:
        return check_call(cmd, shell=True)
    else:
        return call(cmd, shell=True)

def check_cmd_output(cmd):
    proc = Popen(cmd, stdout=PIPE, shell=True)
    exit_code = proc.wait(timeout=5)
    if exit_code != 0:
        raise ValueError(u"No HDHR device found")
    return proc.stdout
#    return check_output(cmd, shell=True)

def terminate_process(psutil_proc):
    if psutil_proc:
        logger().info(u"Killing process id {0}".format(psutil_proc.pid))
        psutil_proc.kill()
        psutil_proc.wait(timeout=1)

def system(cmd, timeout = 60):
    global proc
    logger().info(u"Executing command '{0}'".format(cmd))
    proc = Popen(cmd, close_fds=True, shell=True, stdout=PIPE)
    logger().info(u"PID is {0} for command '{1}'".format(proc.pid, cmd))
    for line in proc.stdout:
        logger().info(u"Process output: {0}".format(line))
    ## Kill process after timeout seconds.
    _timer = Timer(timeout, terminate_process, [proc])
    _timer.start()
    proc.wait(timeout=3) ## Wait for process to complete, increase timeout parameter if default 3 seconds is not enough
    _timer.cancel()
    return proc

def device_online():
    return call_os(HDHomeRun.HDHR_CONFIG + " discover", check=False) == 0

def fail_if_no_device():
    if not device_online():
        raise Exception('No HDHomerun device available on the network')

def wait_pid(pid):
    return os.waitpid(pid)

class HDHomeRun:
    #device_id = "FFFFFFFF"
    HDHR_CONFIG = "hdhomerun_config"
    SYMBOL_RATE = 6900

    def __init__(self):
        self.device_id = self._discover()
        self.tuner_pids = [None, None]
        self._deleteFileIfExists(self._tuner_control_file(0))
        self._deleteFileIfExists(self._tuner_control_file(1))

    def scan_for_channels(self, file_name = 'channels.txt'):
        from .master_import import Channel
        file_path = os.path.join(os.path.curdir, file_name)
        if not os.path.isfile(file_path):
            self._scan_channels_with_tuner(file_name)
        else:
            logger().info(u"Using existing file for reading channels. To force a new scan on the device, delete the '{0}' file".format(file_path))
        Channel.query.delete()
        self._read_channels_file(file_name)

    def start_recording(self, tuner, frequency, program_id, directory):
        self._set_tuner_to_frequency(tuner, frequency)
        self._set_tuner_to_program(tuner, program_id)
        #self.tuner_pids[tuner] = self._spawn_recorder_process_using_bash_script(tuner, directory)
        self.tuner_pids[tuner] = self._spawn_recorder_process(tuner, directory)
        logger().info(u"Process ID for recording on tuner {0}: {1}".format(tuner, self.tuner_pids[tuner].pid))

    def stop_recording(self, tuner):
        psutil_process = self.tuner_pids[tuner]
        if psutil_process and psutil_process.is_running():
            logger().info(u"Stopping process {0} for tuner {1}".format(psutil_process.pid, tuner))
            terminate_process(psutil_process)
        self._reset_tuner_frequency(tuner)
        self.tuner_pids[tuner] = None

#private
    def _deleteFileIfExists(self, file):
        if os.path.exists(file):
            try:
                os.remove(file)
            except:
                logger().error(u"Exception: ",str(sys.exc_info()))

    def _discover(self):
        import re

        hdhr_id = None
        try:
            result = check_cmd_output(HDHomeRun.HDHR_CONFIG + " discover").readlines()
            if len(result) == 1:
                re_match = re.match(r'hdhomerun device (.*) found at .*$', result[0], re.M)
                hdhr_id = re_match.group(1).strip()
                logger().info(u"HDHomerun device id '{0}' found".format(hdhr_id))
        except Exception, err:
            logger().error(err)

        if hdhr_id:
            return hdhr_id
        else:
            logger().info(u"HDHR discover failed, falling back to device id 'ffffffff' - which should work fine as long as there is only one hdhr device on the network")
            return "ffffffff"   ## If only one HDHomerun on network, ffffffff will work as deviceid


    def _scan_channels_with_tuner(self, file_name):
        system(self._hdhr_config_prefix() + " scan /tuner0 {0}".format(file_name), timeout=600)

    def _read_channels_file(self, file_name):
        from .master_import import Channel
        channel_frequency = None
        file = codecs.open(file_name, "r", "utf-8")
        for line in file:
            scanning_search = re.search(r'^SCANNING: (\d*) .*$', line)
            program_search = re.search(r'^PROGRAM (\d*): \d* (.*)$', line)
            if scanning_search:
                channel_frequency = int(scanning_search.group(1))
            elif program_search:
                channel_id = int(program_search.group(1))
                channel_name = program_search.group(2).strip()
                hidden = False
                if channel_name.find('encrypted') != -1 or \
                    channel_name.find("[$]") != -1 or \
                    channel_name.find("DR P") != -1:
                    logger().debug(u"Channel name containing keyword matching auto hide list - hiding channel '{0}'".format(channel_name))
                    hidden = True
                channel = Channel(channel_name, channel_frequency, channel_id, hidden=hidden)
                channel.add(commit=True)

    def _set_tuner_to_frequency(self, tuner, frequency):
        return call_os(
            self._hdhr_config_prefix() + " set /tuner{0}/channel auto:{1}".format(tuner, frequency))

    def _set_tuner_to_program(self, tuner, program_id):
        return call_os(self._hdhr_config_prefix() + " set /tuner{0}/program {1}".format(tuner, program_id))

    def _spawn_recorder_process(self, tuner, directory):
        save_cmd = u'{0} save /tuner{1} "{2}" > "{3}"'.format(self._hdhr_config_prefix(), str(tuner), os.path.join(directory, 'stream.ts'), os.path.join(directory, 'hdhomerun_save.log'))

        logger().info(u"Executing command '{0}'".format(save_cmd))
        return Popen(save_cmd, close_fds=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    def _spawn_recorder_process_using_bash_script(self, tuner, directory):
        open(self._tuner_control_file(tuner), "a") ## Touch file

        command =  u"{0}/hdhomerun_save.sh {1} {2} {3} {4} {5}".format(os.path.dirname(__file__), self.device_id, str(tuner), directory + '/stream.ts' , directory + u"/hdhomerun_save.log", self._tuner_control_file(tuner))

        logger().info(u"Executing command '{0}'".format(command))
        my_hdhr_process = Popen(command, close_fds=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return my_hdhr_process #os.path.dirname(__file__) + "/" + str(tuner)

    def _reset_tuner_frequency(self, tuner):
        return call_os(self._hdhr_config_prefix() + " set /tuner{0}/channel none".format(tuner))

    def _send_control_c_to_process(self, tuner, pid):
        self._deleteFileIfExists(self._tuner_control_file(tuner))
#        FileUtils.rm(tuner_control_file(tuner))
        os.waitpid(pid, os.WNOHANG)

    def _tuner_control_file(self, tuner):
        return os.curdir + "/tuner{0}.lock".format(tuner)

    def _hdhr_config_prefix(self):
        return "{0} {1}".format(HDHomeRun.HDHR_CONFIG, self.device_id)
