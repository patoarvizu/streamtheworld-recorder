FROM ubuntu:16.04

RUN apt-get update && apt-get install -y mplayer nodejs nodejs-legacy npm jq curl awscli
RUN npm install -g xml2json-command

ADD streamtheworld.sh /streamtheworld/