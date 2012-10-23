import sys
from urllib2 import HTTPError

__author__ = 'frj'

import requests

server_url_python='http://localhost:5000'
server_url_ruby='http://localhost:4567'

get_urls = [
    '/api/schedules',
    '/api/upcoming_recordings',
    '/api/channels',
    '/api/channels/139',
    '/api/channels/139/programme_listings/today',
    '/api/programmes/title_search', ## uses ?query arg
    '/api/programmes/search', ## uses ?query arg
    '/api/programmes/626',
    '/api/shows',
    '/api/shows/Unnamed',
    '/api/shows/Unnamed/recordings',
    '/api/shows/Unnamed/recordings/1/',
    '/api/shows/Unnamed/recordings/1/thumbnail.png',
    '/api/shows/Unnamed/recordings/1/stream.ts',
    '/api/status'
]

def do_test(endpoint):
    import time
    for url in get_urls:
        print("Testing {0}\n".format(url))

        start = time.time()
        r = requests.get(endpoint + url)
        stop = time.time()

        print("Request handled in: {0} seconds - returned content type: {1}\n".format((stop-start), r.headers['content-type']))

        try:
            r.raise_for_status()
        except Exception as exception:
            print("ERROR ----> HTTPError occurred: {0}\n".format(exception) )

        print "---------------------------"
        if isinstance(r.json, list):
            for x in r.json:
                print x
        else:
            print r.json
        print "---------------------------"
        #print r.headers

print "Test Python back-end"
do_test(server_url_python)

print "Testing Ruby back-end"
do_test(server_url_ruby)

