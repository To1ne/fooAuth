fooAuth
=========
We don't care about oAuth.

About
-----
fooAuth is a Rails app (running on [Sinatra](http://www.sinatrarb.com/)) that will convert your
basic auth requests (using username + password) to oAuth request (with
all the tokens, keys and secrets...).

Status
------
fooAuth is still in development phase (actually even still in design
phase). Currently I am able to post a tweet on Twitter using fooAuth.

Usage
-----
Pass the following parameters to you fooAuth requests:
+ foo_site: the API site you are using (e.g. 'http://api.twitter.com')
+ foo_page: the API page you want to send to request to (e.g. '/statuses/update.json')
+ foo\_consumer\_key & foo\_consumer\_secret: oAuth consumer key and
  secret acquired from API you are using (for twitter use:
  http://dev.twitter.com/apps/new)
+ foo_username:
+ foo_password:
Any other parameter will be passed to the 'foo_page' request.

### Example
Assume the following environment variables:
+ `USER`: Twitter @username
+ `PASS`: Twitter password
+ `CONSUMER_KEY`: Twitter API consumer key
+ `CONSUMER_SECRET`: Twitter API consumer secret
+ `HOST`: the host where you are running fooAuth (e.g. `http://127.0.0.1:4567`)
+ `SITE`: the API site, which is `http://api.twitter.com` for Twitter

#### Example 1
Get latest tweet from your home timeline:
    curl -u ${USER}:${PASS} -G \
        --data-urlencode foo_consumer_key="${CONSUMER_KEY}"  --data-urlencode foo_consumer_secret="${CONSUMER_SECRET}" \
        --data-urlencode count="1" \
        ${HOST}/${SITE}/statuses/home_timeline.json

#### Example 2
Post a new tweet:
    curl -u ${USER}:${PASS} \
        --data-urlencode foo_consumer_key="${CONSUMER_KEY}"  --data-urlencode foo_consumer_secret="${CONSUMER_SECRET}" \
        --data-urlencode status="Posting a tweet using fooAuth" \
        ${HOST}/${SITE}/statuses/update.json


