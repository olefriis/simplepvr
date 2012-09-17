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
from subprocess import Popen, PIPE

from .pvr_logger import logger

proc = None
def kill_proc():
    if proc:
        proc.kill()
    else:
        logger().warn("No process to kill")

def system(cmd, timeout = 60):
    logger().info("Executing command '{}'".format(cmd))
    proc = Popen(cmd, shell=True)
    ## Kill process after timeout seconds.
    t = Timer(timeout, kill_proc).start()
    proc.wait() ## Wait for process to complete, increase timeout parameter if default 60 seconds is not enough

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

        self._scan_channels_with_tuner(file_name)
        Channel.query.all().delete()
        self._read_channels_file(file_name)

    def start_recording(self, tuner, frequency, program_id, directory):
        self._set_tuner_to_frequency(tuner, frequency)
        self._set_tuner_to_program(tuner, program_id)
        self.tuner_pids[tuner] = self._spawn_recorder_process(tuner, directory)
        logger().info("Process ID for recording on tuner {0}: {1}".format(tuner, self.tuner_pids[tuner]))

    def stop_recording(self, tuner):
        pid = self.tuner_pids[tuner]
        logger().info("Stopping process {0} for tuner {1}".format(pid, tuner))
        self._send_control_c_to_process(tuner, pid)
        self._reset_tuner_frequency(tuner)
        self.tuner_pids[tuner] = None

#private
    def _deleteFileIfExists(self, file):
        if os.path.exists(file):
            try:
                os.remove(file)
            except:
                logger().error("Exception: ",str(sys.exc_info()))

    def _discover(self):
        return "ffffffff" ## If only HDHomerun on network, ffffffff will work as deviceid
        #IO.popen('hdhomerun_config discover') do |pipe|
        #output = pipe.read
        #return $1 if output =~ /^hdhomerun device (.*) found at .*$/

        #raise Exception, "No device found: #{output}"

    def _scan_channels_with_tuner(self, file_name):
        system(self._hdhr_config_prefix() + " scan /tuner0 {0}".format(file_name))

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
                channel = Channel(channel_name, channel_frequency, channel_id)
                Channel.add(channel, channel_name, channel_frequency, channel_id)

    def _set_tuner_to_frequency(self, tuner, frequency):
        system(self._hdhr_config_prefix() + " set /tuner{}/channel auto:{}".format(tuner, frequency))

    def _set_tuner_to_program(self, tuner, program_id):
        system(self._hdhr_config_prefix() + " set /tuner{}/program {}".format(tuner, program_id))

    def _spawn_recorder_process(self, tuner, directory):
        open(self._tuner_control_file(tuner), "a") ## Touch file

        command =  "{}/hdhomerun_save.sh {} {} {} {} {}".format(os.path.dirname(__file__), self.device_id, str(tuner), directory + '/stream.ts', directory + '/hdhomerun_save.log', self._tuner_control_file(tuner))
        r = subprocess.call(command, shell=True)
        print r
        return os.path.dirname(__file__) + "/" + str(tuner)

    def _reset_tuner_frequency(self, tuner):
        system(self._hdhr_config_prefix() + " set /tuner{0}/channel none".format(tuner))

    def _send_control_c_to_process(self, tuner, pid):
        self._deleteFileIfExists(self._tuner_control_file(tuner))
#        FileUtils.rm(tuner_control_file(tuner))
        os.waitpid(pid, os.WNOHANG)

    def _tuner_control_file(self, tuner):
        return os.curdir + "/tuner{0}.lock".format(tuner)

    def _hdhr_config_prefix(self):
        return "{0} {1}".format(HDHomeRun.HDHR_CONFIG, self.device_id)