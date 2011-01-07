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

# TODO why is the dummy needed?
data=\
'foo_consumer_key="'${CONSUMER_KEY}'"&'\
'foo_consumer_secret="'${CONSUMER_SECRET}'"&'\
'count=1'

#\
#"username_or_email=\"${USER}\"&"\
#"password=\"${PASS}\"&"\
#"status=\"${STATUS}\""

# POST curl -u "${USER}:${PASS}" -d "${data}" 0.0.0.0:4567/"${SITE}${PAGE}"
echo curl -u "${USER}:${PASS}" 0.0.0.0:4567/"${SITE}${PAGE}?${data}"
curl -u "${USER}:${PASS}" 0.0.0.0:4567/"${SITE}"
#${PAGE}?${data}"

