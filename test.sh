#!/bin/sh
set -e

# Hardcoded values (temporary)
#HOST='http://127.0.0.1:4567'
HOST='http://fooauth.heroku.com'
SITE='http://api.twitter.com'
CONSUMER_KEY='j0XVctwQDETgM8Twy2Qew'
CONSUMER_SECRET='VhNSTD3eDQDuJ2EYbVnyZTZfydQ5kVX2SKbTGIBSuc'
# Read login from stdin
USER=$1
PASS=$2

# TODO for loop for all other arguments from stdin

# GET home timeline
curl -u ${USER}:${PASS} -G --data-urlencode foo_consumer_key="${CONSUMER_KEY}" --data-urlencode foo_consumer_secret="${CONSUMER_SECRET}"  --data-urlencode count="1" ${HOST}/${SITE}/statuses/home_timeline.json

# POST new status
#curl -u ${USER}:${PASS} --data-urlencode status="$3" --data-urlencode foo_consumer_key="${CONSUMER_KEY}" --data-urlencode foo_consumer_secret="${CONSUMER_SECRET}"  --data-urlencode count="1" ${HOST}/${SITE}/statuses/update.json

