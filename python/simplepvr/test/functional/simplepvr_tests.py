__author__ = 'frj'

import os
from flask import Flask, json
from flask.ext.sqlalchemy import SQLAlchemy
import unittest
import tempfile
import simple_pvr.server as pvr
from simple_pvr.programme import Programme
from simple_pvr.channel import Channel
from simple_pvr.schedule import Schedule
from datetime import datetime, timedelta

class SimplePVRTestCase(unittest.TestCase):

    def setUp(self):
        from sqlalchemy.engine import create_engine

#        self.db_fd, tmp_file_path = tempfile.mkstemp(suffix=".sqlite", dir=os.curdir)
        pvr.app.config['DATABASE'] = ":memory:"#os.path.relpath(tmp_file_path)
        pvr.app.config['TESTING'] = True
        pvr.app.config['SQLALCHEMY_ENGINE'] = 'sqlite://'
        pvr.app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + pvr.app.config['DATABASE']

        self.app = pvr.app.test_client()
        pvr.connect_db()

        #Create the schema
        pvr.db.create_all()
        self._create_test_data()

        Schedule.query.delete()
        pvr.db.session.commit()

    def tearDown(self):
        pvr.db.drop_all()
        pass
        #print "tearDown"
       # os.close(self.db_fd)
       # os.unlink(pvr.app.config['DATABASE'])


#'/api/schedules',                                                                # test_schedules
#'/api/upcoming_recordings',                                                      # test_upcoming_recordings
# '/api/channels',                                                                # test_channels
# '/api/channels/139',                                                            # test_channel
#'/api/channels/139/programme_listings/today',                                    # test_channel_listings
#'/api/programmes/title_search', ## uses ?query arg                               # test_programmes_title_search
#'/api/programmes/search', ## uses ?query arg                                     # test_programmes_search
#'/api/programmes/626',                                                           # test_programmes
#'/api/shows',                                                                    # test_shows
#'/api/shows/Unnamed',                                                            # test_show
#'/api/shows/Unnamed/recordings',                                                 # test_show_recordings
#'/api/shows/Unnamed/recordings/1/',                                              # test_show_recording_number
#'/api/shows/Unnamed/recordings/1/thumbnail.png',
#'/api/shows/Unnamed/recordings/1/stream.ts',
#'/api/status'
# '/api/schedules', methods=['POST'])                                             # test_create_delete_schedule
# '/api/schedules/<int:sched_id>', methods=['DELETE'])                            # test_create_delete_schedule
# '/api/schedules/reload', methods=['POST'])                                      # test_upcoming_recordings
# '/api/channels/<int:chan_id>/hide', methods=['POST'])                           # test_hide_show_channel
# '/api/channels/<int:chan_id>/show', methods=['POST'])                           # test_hide_show_channel
# '/api/programmes/<int:prog_id>/record_on_any_channel', methods=['POST'])        # test_programmes_record_on_any_channel
# '/api/programmes/<int:prog_id>/record_on_this_channel', methods=['POST'])       # test_programmes_record_on_this_channel
# '/api/programmes/<programme_id>/record_just_this_programme', methods=['POST'])  # test_programmes_record_just_this_programme
# '/api/shows/<show_name>', methods=['DELETE'])
# '/api/shows/<show_name>/recordings/<episode>', methods=['DELETE'])


    def test_channels(self):
        json_response = self._get_for_json('/api/channels')
        test_channel = json_response[0]
        assert test_channel['id'] == 1
        assert test_channel['name'] == "Kanal 1"
        assert test_channel['hidden'] == False
        assert len(test_channel['upcoming_programmes']) == 1
        assert test_channel['upcoming_programmes'][0]['title'] == "Testudsendelse i morgen"

    def test_hide_show_channel(self):

        data = {'title': "Testudsendelse", 'channel_id': 1}
        response = self.app.post('/api/channels/1/hide', data=json.dumps(data), content_type='application/json')
        self.assertEqual(response.status_code, 200)
        json_response = json.loads(response.data)
        assert json_response['hidden'] == True

        data = {'title': "Testudsendelse", 'channel_id': 1}
        response = self.app.post('/api/channels/1/show', data=json.dumps(data), content_type='application/json')
        self.assertEqual(response.status_code, 200)
        json_response = json.loads(response.data)
        assert json_response['hidden'] == False


    def test_channel(self):

        # First we retrieve channel 2 which should have no programmes
        json_response = self._get_for_json('/api/channels/2')
        assert json_response['name'] == "Kanal 2"
        current_programme_ = json_response['current_programme']
        assert current_programme_ is None

        ## Repeat the test for channel 1, which has a current programme
        json_response = self._get_for_json('/api/channels/1')
        assert json_response['name'] == "Kanal 1"
        current_programme_ = json_response['current_programme']
        assert current_programme_ is not None
        assert current_programme_['title'] == "Testudsendelse"

    def test_channel_listings(self):

        json_response = self._get_for_json('/api/channels/1/programme_listings/today')
        programmes_day0_list = json_response['days'][0]['programmes']
        assert len(programmes_day0_list) == 1

    def test_schedules(self):

        assert len(pvr.db.session.query(Schedule).all()) == 0

        json_response = self._get_for_json('/api/schedules')
        assert len(json_response) == 0

        p = Programme.query.get(2)
        schedule = Schedule(p.title, 'specification', datetime.now(), Channel.query.get(1))
        schedule.add(True)

        json_response = self._get_for_json('/api/schedules')
        assert len(json_response) == 1
        assert json_response[0]['title'] == schedule.title
        assert json_response[0]['channel']['id'] == 1

    def test_create_delete_schedule(self):
        data = {'title': "Testudsendelse", 'channel_id': 1}
        response = self.app.post('/api/schedules', data=json.dumps(data), content_type='application/json')
        self.assertEqual(response.status_code, 200)
        json_response = json.loads(response.data)
        schedule_id = json_response['id']
        assert schedule_id == 1

        s = Schedule.query.get(schedule_id)
        assert s.title == "Testudsendelse"
        delete_uri = "/api/schedules/" + str(schedule_id)
        response = self.app.delete(delete_uri)
        assert response.status_code == 204


    def test_upcoming_recordings(self):

        p = Programme.query.get(1)
        schedule = Schedule(p.title, 'specification', p.start_time, p.channel)
        schedule.add(True)

        self.app.post('/api/schedules/reload') ## Force reload of upcoming recordings

        json_response = self._get_for_json('/api/upcoming_recordings')
        assert len(json_response) == 1


    def test_programmes(self):

        json_response = self._get_for_json('/api/programmes/1')
        assert json_response['title'] == 'Testudsendelse'
        assert json_response['channel']['name'] == "Kanal 1"


    def test_programmes_search(self):
        json_response = self._get_for_json('/api/programmes/search?query=Testudsendelse')
        assert len(json_response) == 2
        res0 = json_response[0]
        assert res0['title'] == "Testudsendelse 3"
        assert res0['channel']['name'] == "Kanal 3"

        res1 = json_response[1]
        assert res1['title'] == "Testudsendelse i morgen"
        assert res1['channel']['name'] == "Kanal 1"

    def test_programmes_title_search(self):
        json_response = self._get_for_json('/api/programmes/title_search?query=Testudsendelse')
        assert len(json_response) == 2
        res0 = json_response[0]
        assert res0['title'] == "Testudsendelse 3"
        assert res0['channel']['name'] == "Kanal 3"

        res1 = json_response[1]
        assert res1['title'] == "Testudsendelse i morgen"
        assert res1['channel']['name'] == "Kanal 1"

    def test_programmes_record_on_any_channel(self):
        c2 = Channel.query.get(2)
        start_time = datetime.now() + timedelta(days=3)
        stop_time = start_time + timedelta(minutes=45)

        programme_id = 2
        p_test = Programme.query.get(programme_id)
        title = p_test.title

        # Create an extra programme with the same title as programme2 - but scheduled on a different channel
        Programme(c2, title, "sub2", "desc2", start_time, stop_time, (stop_time-start_time).total_seconds(), "1/4", True).add(True)

        rec_url = "/api/programmes/{}/record_on_any_channel".format(programme_id)
        rv = self.app.post(rec_url)
        assert rv.status_code == 200
        json_response = json.loads(rv.data)
        assert json_response['id'] == 2
        assert json_response['is_scheduled'] == True

        self.app.post('/api/schedules/reload') ## Force reload of upcoming recordings

        json_response = self._get_for_json('/api/upcoming_recordings')
        expected_length = 2
        actual_length = len(json_response)
        assert actual_length == expected_length, "Length of response ({}) is not {}".format(actual_length, expected_length)


    def test_programmes_record_on_this_channel(self):

        c2 = Channel.query.get(2)
        start_time = datetime.now() + timedelta(days=3)
        stop_time = start_time + timedelta(minutes=45)

        programme_id = 2
        p_test = Programme.query.get(programme_id)
        title = p_test.title

        # Create an extra programme with the same title as programme2 - but scheduled on a different channel
        Programme(c2, title, "sub2", "desc2", start_time, stop_time, (stop_time-start_time).total_seconds(), "1/4", True).add(True)

        rec_url = "/api/programmes/{}/record_on_this_channel".format(programme_id)
        rv = self.app.post(rec_url)
        assert rv.status_code == 200
        json_response = json.loads(rv.data)
        assert json_response['id'] == 2
        assert json_response['is_scheduled'] == True

        self.app.post('/api/schedules/reload') ## Force reload of upcoming recordings

        json_response = self._get_for_json('/api/upcoming_recordings')
        expected_length = 1 ## Only one show on this channel with this title
        actual_length = len(json_response)
        assert actual_length == expected_length, "Length of response ({}) is not {}".format(actual_length, expected_length)

    def test_programmes_record_just_this_programme(self):

        c2 = Channel.query.get(2)
        start_time = datetime.now() + timedelta(days=3)
        stop_time = start_time + timedelta(minutes=45)

        programme_id = 2
        p_test = Programme.query.get(programme_id)
        title = p_test.title

        # Create an extra programme with the same title as programme2 - scheduled on the same channel
        Programme(p_test.channel, title, "sub2", "desc2", start_time, stop_time, (stop_time-start_time).total_seconds(), "3/4", True).add(True)

        rec_url = "/api/programmes/{}/record_just_this_programme".format(programme_id)
        rv = self.app.post(rec_url)
        assert rv.status_code == 200
        json_response = json.loads(rv.data)
        assert json_response['id'] == 2
        assert json_response['is_scheduled'] == True

        self.app.post('/api/schedules/reload') ## Force reload of upcoming recordings

        json_response = self._get_for_json('/api/upcoming_recordings')
        expected_length = 1 ## Only one show on this channel with this title and start time
        actual_length = len(json_response)
        assert actual_length == expected_length, "Length of response ({}) is not {}".format(actual_length, expected_length)


    def test_shows(self):
        import shutil

        recordings_dir = os.curdir + "/recordings"
        episode_dir = recordings_dir + "/TestShow/1"

        ## clear any files that might reside in the test recordings dir
        shutil.rmtree(recordings_dir, ignore_errors=True)

        json_response = self._get_for_json('/api/shows')
        assert len(json_response) == 0

        try:
            os.makedirs(episode_dir)

            ## Put some recordings in the recordings dir
            stream_ts = open(os.path.join(episode_dir, "stream.ts"), 'w')
            metadata = open(os.path.join(episode_dir, "metadata.yaml"), 'w')

            json_response = self._get_for_json('/api/shows')
            assert len(json_response) == 1
            assert json_response[0]['name'] == 'TestShow'

        finally:
            stream_ts.close()
            metadata.close()
            shutil.rmtree(recordings_dir, ignore_errors=True)

    def test_show(self):
        import shutil

        show_name = "TestShow"
        recording_number = "1"

        recordings_dir = os.curdir + "/recordings"
        episode_dir = recordings_dir + "/{}/{}".format(show_name, recording_number)

        ## clear any files that might reside in the test recordings dir
        shutil.rmtree(recordings_dir, ignore_errors=True)

        url_show = "/api/shows/"+show_name
        json_response = self._get_for_json(str(url_show), 404)

        try:
            os.makedirs(episode_dir)

            ## Put some recordings in the recordings dir
            stream_ts = open(os.path.join(episode_dir, "stream.ts"), 'w')
            metadata = open(os.path.join(episode_dir, "metadata.yaml"), 'w')

            json_response = self._get_for_json('/api/shows')
            assert len(json_response) == 1
            assert json_response[0]['name'] == 'TestShow'

        finally:
            stream_ts.close()
            metadata.close()
            shutil.rmtree(recordings_dir, ignore_errors=True)


    def test_show_recordings(self):
        import shutil

        show_name = "TestShow"
        recording_number = "1"

        recordings_dir = os.curdir + "/recordings"
        episode_dir = recordings_dir + "/{}/{}".format(show_name, recording_number)

        ## clear any files that might reside in the test recordings dir
        shutil.rmtree(recordings_dir, ignore_errors=True)

        url_show = "/api/shows/"+show_name+"/recordings"
        json_response = self._get_for_json(str(url_show), 404)

        try:
            os.makedirs(episode_dir)

            ## Put some recordings in the recordings dir
            stream_ts = open(os.path.join(episode_dir, "stream.ts"), 'w')
            metadata = open(os.path.join(episode_dir, "metadata.yml"), 'w')

            metadata.write("channel: 1\n")
            metadata.write("subtitle: sub\n")
            metadata.write("description: desc\n")
            metadata.write("start_time: 2012-10-01 21:55:00\n")
            metadata.write("duration: 600\n")
            metadata.flush()

            json_response = self._get_for_json(url_show)
            assert len(json_response) == 1
            assert json_response[0]['show_id'] == 'TestShow'

        finally:
            stream_ts.close()
            metadata.close()
            shutil.rmtree(recordings_dir, ignore_errors=True)


    def test_show_recording_number(self):
        import shutil


        show_name = "TestShow"
        recording_number = "1"

        recordings_dir = pvr.app.config['RECORDINGS_PATH'] #os.curdir + "/recordings"
        episode_dir = recordings_dir + "/{}/{}".format(show_name, recording_number)

        ## clear any files that might reside in the test recordings dir
        shutil.rmtree(recordings_dir, ignore_errors=True)

        url_show = "/api/shows/"+show_name+"/recordings/" + recording_number

        self._get_for_json(str(url_show), 404)

        try:
            os.makedirs(episode_dir)

            ## Put some recordings in the recordings dir
            stream_ts = open(os.path.join(episode_dir, "stream.ts"), 'w')
            metadata = open(os.path.join(episode_dir, "metadata.yml"), 'w')

            metadata.write("channel: 1\n")
            metadata.write("subtitle: sub\n")
            metadata.write("description: desc\n")
            metadata.write("start_time: 2012-10-01 21:55:00\n")
            metadata.write("duration: 600\n")
            metadata.flush()

            json_response = self._get_for_json(url_show)
            assert json_response['show_id'] == 'TestShow'

        finally:
            stream_ts.close()
            metadata.close()
            shutil.rmtree(recordings_dir, ignore_errors=True)



##### Utility methods
    def _post_for_json(self, url):
        rv = self.app.post(url)
        return self._assert_status_for_json(rv)

    def _delete_for_json(self, url):
        rv = self.app.delete(url)
        return self._assert_status_for_json(rv)

    def _get_for_json(self, url, status = 200):
        rv = self.app.get(url)
        return self._assert_status_for_json(rv, status=status)

    def _assert_status_for_json(self, rv, status=200):
        assert rv.status_code == status
        rv_response = list(rv.response)
        expected_length = 1 if status == 200 else 0
        assert len(rv_response) == expected_length
        json_response = None
        if expected_length >0:
            json_response = json.loads(rv_response[0])
        return json_response

##### SETUP DATA FOR TESTING #######
    def _create_channels(self):
        if not len(pvr.db.session.query(Channel).all()) == 3:
            ## Preload with some test data
            Channel("Kanal 1", 514000000, 119).add(True)
            Channel("Kanal 2", 432000000, 123).add(True)
            Channel("Kanal 3", 234000000, 987).add(True)

            assert len(pvr.db.session.query(Channel).all()) == 3

    def _create_programmes(self):

        if not len(pvr.db.session.query(Programme).all()) == 3:
            now = datetime.now()
            start = now + timedelta(minutes=30)
            stop_now = now + timedelta(minutes=60)
            stop = start + timedelta(minutes=60)
            start_tomorrow = now + timedelta(days = 1)
            end_tomorrow = now + timedelta(days = 1, minutes = 30)
            Programme(Channel.query.get(1), "Testudsendelse", "sub", "desc", now, stop_now, (stop_now-now).total_seconds()).add(True)
            Programme(Channel.query.get(1), "Testudsendelse i morgen", "sub", "desc", start_tomorrow, end_tomorrow, (end_tomorrow-start_tomorrow).total_seconds()).add(True)
            Programme(Channel.query.get(3), "Testudsendelse 3", "sub", "desc", start, stop, (stop-start).total_seconds() ).add(True)

    def _create_test_data(self):
        self._create_channels()
        self._create_programmes()

if __name__ == '__main__':
    unittest.main()