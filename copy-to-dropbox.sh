#!/usr/bin/env python

import dropbox
import os
import json

tokens = json.load(open('/home/ubuntu/.secrets/tokens.json'))
dbx = dropbox.Dropbox(tokens['DropBox'])

for file in os.listdir('/home/ubuntu/streamtheworld-recorder'):
    if file.endswith('.mp3'):
        file_path = os.path.join("/home/ubuntu/streamtheworld-recorder", file)
        with open(file_path, 'rb') as f:
            dbx.files_upload(f.read(), os.path.join("/", file), dropbox.files.WriteMode.overwrite)
