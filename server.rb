require 'rubygems'
require 'oauth'
require 'sinatra'
require 'net/http'
require 'hpricot'
require 'pp'

post '/' do
  # Start
  site            = params['foo_site']
  consumer_key    = params['foo_consumer_key']
  consumer_secret = params['foo_consumer_secret']

  consumer=OAuth::Consumer.new(consumer_key, consumer_secret, {:site => site})
  request_token=consumer.get_request_token
  auth_url = request_token.authorize_url
  # Authenticate
  url = URI.parse(auth_url)
  Net::HTTP.start(url.host, url.port) do |http|
    # Get input form
    res = http.get url.request_uri
    # Check response
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      # OK
    else
      res.error!
    end
    # Parse the form
    doc = Hpricot(res.body)
    inputs = doc.search('input')
    # Fill in form
    form = Hash.new
    inputs.each do |inp|
      key = inp.attributes['name']
      if (params.has_key?(key))
        form[key] = params[key]
      else
        form[key] = inp.attributes['value']
      end
    end
    # Post form
    res = Net::HTTP.post_form url, form
    # Check response
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      # OK
    else
      res.error!
    end
    res.body
  end  # http session
end
