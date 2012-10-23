import unittest, os
from simple_pvr.hdhomerun import *
import psutil
from datetime import datetime, timedelta

class HDHomerunTestCase(unittest.TestCase):

    def setUp(self):
        self.sleep_time = 3
        self.cmd = "sleep {0}".format(self.sleep_time)

        self.hdhomerun = HDHomeRun()

    @unittest.skipUnless(device_online(), "HDHomerun device is not available")
    def test_set_tuner_freq(self):
        exit_code = self.hdhomerun._set_tuner_to_frequency(0, 514000000)
        self.assertEqual(0, exit_code)

    @unittest.skipUnless(device_online(), "HDHomerun device is not available")
    def test_set_tuner_program(self):
        exit_code = self.hdhomerun._set_tuner_to_program(0, 1230)
        self.assertEqual(0, exit_code)

    def test_wait_for_long_running_command(self):
        start = datetime.now()
        self.assertEqual(0, call_os(self.cmd))
        stop = datetime.now()
        duration = (stop-start).total_seconds()
        self.assertLessEqual(self.sleep_time, duration)

    def test_timeout_kill_long_running_command(self):
        start = datetime.now()
        timeout = 1
        system(self.cmd, timeout=timeout)
        stop = datetime.now()
        duration = (stop-start).total_seconds()
        self.assertEqual(timeout, duration//timeout)

    def test_spawn_recorder_using_shell_script(self):
        start = datetime.now()
        process = self.hdhomerun._spawn_recorder_process_using_bash_script(0, os.getcwd())
        stop = datetime.now()
        duration = (stop-start).total_seconds()
        print "Duration: ", duration, " seconds"
        print "Process: ", process

        os.system("sleep 4")

        self.assertTrue(process.is_running())

        print process.cmdline
        print process.get_cpu_times()
        print process.get_cpu_percent(interval=1.0)
        print process.get_open_files()
        print "Running: ", process.is_running()

        terminate_process(process)
        self.assertFalse(process.is_running())

    def test_spawn_recorder_using_direct(self):
        start = datetime.now()
        process = self.hdhomerun._spawn_recorder_process(0, os.getcwd())
        stop = datetime.now()
        duration = (stop-start).total_seconds()

        self.assertLess(duration, self.sleep_time)

        os.system("sleep 4")

        self.assertTrue(process.is_running())

        terminate_process(process)

        self.assertFalse(process.is_running())

    def test_stuff(self):
        import re
        start = datetime.now()

        discover_cmd = "hdhomerun_config discover"
        output = check_cmd_output(discover_cmd)
        re_match = re.match(r'hdhomerun device (.*) found at .*$', output, re.M)
        print "HDHomerun id: ", re_match.group(1).strip()

