#!/bin/bash

for v in `ec2metadata --user-data`; do
  export `echo "${v}" | cut -d "=" -f1`=`echo ${v} | cut -d "=" -f2`
done
