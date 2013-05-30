#!/bin/bash

source $(dirname $BASH_SOURCE)/parse-user-data.sh

date=`date +%d/%m/%y\ %H:%M`
/usr/bin/python streamtheworld.py $1 r $2
echo $date | mutt -s "$1 $date" -a `ls -1t *$1*mp3 | head -1` -- patoarvizu@gmail.com
