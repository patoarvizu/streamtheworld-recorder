FROM ubuntu:16.04

RUN apt-get update && apt-get install -y mplayer nodejs nodejs-legacy npm jq curl
RUN npm install -g xml2json-command

ADD streamtheworld.sh /streamtheworld/
RUN chmod +x /streamtheworld/streamtheworld.sh