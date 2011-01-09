#!/bin/sh
set -e

# Hardcoded values (temporary)
SITE='http://api.twitter.com'
#SITE='http%3A%2F%2Fapi.twitter.com'
PAGE='/statuses/update.json'
#PAGE='%2Fstatuses%2Fhome_timeline.json'
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

#curl -u ${USER}:${PASS} http://0.0.0.0:4567/${SITE}${PAGE}\?${data} # GET
wget --user=${USER} --password=${PASS} http://0.0.0.0:4567/${SITE}${PAGE}\?${data} # GET
#cmd="curl -u \"${USER}:${PASS}\" -d '' 0.0.0.0:4567/\"${SITE}${PAGE}?${data}\"" # POST
# POST cmd=curl -u "${USER}:${PASS}" -d "${data}" 0.0.0.0:4567/"${SITE}${PAGE}"
#${PAGE}?${data}"

