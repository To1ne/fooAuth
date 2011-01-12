#!/bin/sh
set -e

# Hardcoded values (temporary)
SITE='http://api.twitter.com'
#PAGE='/statuses/update.json'
PAGE='/statuses/home_timeline.json'
CONSUMER_KEY='j0XVctwQDETgM8Twy2Qew'
CONSUMER_SECRET='VhNSTD3eDQDuJ2EYbVnyZTZfydQ5kVX2SKbTGIBSuc'
# Read login from stdin
USER=$1
PASS=$2
STATUS=$3

# TODO for loop for all other arguments from stdin

# GET
curl -u ${USER}:${PASS} -G --data-urlencode foo_consumer_key="${CONSUMER_KEY}" --data-urlencode foo_consumer_secret="${CONSUMER_SECRET}"  --data-urlencode count="1" http://127.0.0.1:4567/${SITE}${PAGE}

