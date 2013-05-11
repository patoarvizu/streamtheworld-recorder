#!/usr/bin/env python

from random import choice
import os
import sys
import urllib2
import xml.dom.minidom as minidom
import datetime
import time
import subprocess

def validate_callsign(cs):
        '''
        Normal callsign format is 'WWWWFFAAA', where 'WWWW' is the radio station
        callsign, 'FF' is either 'AM' or 'FM', and 'AAA' is always 'AAC'.
        For this function, we expect the 'WWWWFF' part as input.
        '''
        if not cs or not isinstance(cs, str):
                raise ValueError('callsign \'%s\' is not a string.' % cs)
        #if not cs.endswith('AAC'):
        #        cs = cs + 'AAC'
        return cs

def make_request(callsign):
        host = 'playerservices.streamtheworld.com'
        req = urllib2.Request(
                        'http://%s/api/livestream?version=1.5&mount=%s&lang=en' %
                        (host, callsign))
        req.add_header('User-Agent', 'Mozilla/5.0')
        print callsign
        return req

## Example XML document we are parsing follows, as the minidom code is so beautiful to follow
#
#<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
#<live_stream_config version="1" xmlns="http://provisioning.streamtheworld.com/player/livestream-1.2">
#       <mountpoints>
#               <mountpoint>
#                       <status>
#                               <status-code>200</status-code>
#                               <status-message>OK</status-message>
#                       </status>
#                       <servers>
#                               <server sid="5203">
#                                       <ip>77.67.109.167</ip>
#                                       <ports>
#                                               <port>80</port>
#                                               <port>443</port>
#                                               <port>3690</port>
#                                       </ports>
#                               </server>
#                               <!-- multiple server elements usually present -->
#                       </servers>
#                       <mount>WXYTFMAAC</mount>
#                       <format>FLV</format>
#                       <bitrate>64000</bitrate>
#                       <authentication>0</authentication>
#                       <timeout>0</timeout>
#               </mountpoint>
#       </mountpoints>
#</live_stream_config>

def t(element):
        '''get the text of a DOM element'''
        return element.firstChild.data

def check_status(ele):
        # should only be one status element inside a mountpoint
        status = ele.getElementsByTagName('status')[0]
        if t(status.getElementsByTagName('status-code')[0]) != '200':
                msg = t(status.getElementsByTagName('status-message')[0])
                raise Exception('Error locating stream: ' + msg)

def create_stream_urls(srcfile):
        doc = minidom.parse(srcfile)
        mp = doc.getElementsByTagName('mountpoint')[0]
        check_status(mp)
        mt = t(mp.getElementsByTagName('mount')[0])
        allurls = []
        for s in mp.getElementsByTagName('server'):
                # a thing of beauty, right?
                ip = t(s.getElementsByTagName('ip')[0])
                ports = [t(p) for p in s.getElementsByTagName('port')]
                # yes, it is always HTTP. We see ports 80, 443, and 3690 usually
                urls = ['http://%s:%s/%s' % (ip, p, mt) for p in ports]
                allurls.extend(urls)
        return allurls

def start_mplayer(location):
        return os.system('mplayer %s' % location)

def record_mplayer(location, minutes, callsign):
        p = subprocess.Popen(['mplayer', location, '-forceidx', '-dumpstream', '-dumpfile', datetime.datetime.now().strftime("%y-%m-%d-%H-%M") + '-' + callsign + '.mp3'])
        time.sleep(minutes * 60)
        p.terminate()
        sys.exit(0)

if __name__ == '__main__':
        if len(sys.argv) < 2:
                print 'usage: station callsign must be the first argument'
                sys.exit(1)

        if(sys.argv[1] == 'radioacir'):
            if len(sys.argv) >= 3 and sys.argv[2] == 'r':
                if len(sys.argv) == 4:
                    sys.exit(record_mplayer('http://76.73.20.18:8230/', int(sys.argv[3]), 'radioacir'))
                else:
                    sys.exit(record_mplayer('http://76.73.20.18:8230/', 60, 'radioacir'))
            sys.exit(start_mplayer('http://76.73.20.18:8230/'))

        callsign = validate_callsign(sys.argv[1])

        req = make_request(callsign)
        result = urllib2.urlopen(req)

        urls = create_stream_urls(result)
        if len(urls) > 0:
                u = choice(urls)
                if len(sys.argv) >= 3 and sys.argv[2] == 'r':
                    if len(sys.argv) == 4:
                        sys.exit(record_mplayer(u, int(sys.argv[3]), callsign))
                    else:
                        sys.exit(record_mplayer(u, 60, callsign))
                else:
                    sys.exit(start_mplayer(u))
        sys.exit(1)
