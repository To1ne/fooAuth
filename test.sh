#!/bin/sh
set -e

# Hardcoded values (temporary)
SITE='http://api.twitter.com'
CONSUMER_KEY='j0XVctwQDETgM8Twy2Qew'
CONSUMER_SECRET='VhNSTD3eDQDuJ2EYbVnyZTZfydQ5kVX2SKbTGIBSuc'
# Read login from stdin
USER=$1
PASS=$2

# TODO why is the dummy needed?
data=\
"foo_site=\"${SITE}\"&"\
"foo_consumer_key=\"${CONSUMER_KEY}\"&"\
"foo_consumer_secret=\"${CONSUMER_SECRET}\"&"\
"username_or_email=\"${USER}\"&"\
"password=\"${PASS}\""

curl -d "${data}" 0.0.0.0:4567
