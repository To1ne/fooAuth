#!/bin/sh
set -e

# Hardcoded values (temporary)
SITE='http://api.twitter.com'
PAGE='/statuses/update.json'
CONSUMER_KEY='j0XVctwQDETgM8Twy2Qew'
CONSUMER_SECRET='VhNSTD3eDQDuJ2EYbVnyZTZfydQ5kVX2SKbTGIBSuc'
# Read login from stdin
USER=$1
PASS=$2
STATUS=$3

# TODO why is the dummy needed?
data=\
"foo_site=\"${SITE}\"&"\
"foo_page=\"${PAGE}\"&"\
"foo_consumer_key=\"${CONSUMER_KEY}\"&"\
"foo_consumer_secret=\"${CONSUMER_SECRET}\"&"\
"username_or_email=\"${USER}\"&"\
"password=\"${PASS}\"&"\
"status=\"${STATUS}\""

curl -d "${data}" 0.0.0.0:4567

