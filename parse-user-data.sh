#!/bin/sh

for line in `ec2metadata --user-data`; do
  export `echo "${line}" | cut -d "=" -f1`=`echo ${line} | cut -d "=" -f2`
done