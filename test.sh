#!/bin/sh
set -e

# Hardcoded values (temporary)
SITE='http://api.twitter.com'
CONSUMER_KEY='wh5EMIRW7CCWYGZbAVMDA'
CONSUMER_SECRET='vCXJ81ARTjWJm6i8qw9EzfzZp6gWPR9CNUUNuh3Gh8'
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
