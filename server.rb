require 'rubygems'
require 'oauth'
require 'sinatra'
require 'net/http'
require 'hpricot'
require 'pp'

post '/' do
  # Handle parameters
  site            = params['foo_site']
  consumer_key    = params['foo_consumer_key']
  consumer_secret = params['foo_consumer_secret']
  # Get authentication url
  consumer=OAuth::Consumer.new(consumer_key, consumer_secret, {:site => site})
  request_token=consumer.get_request_token
  auth_url = request_token.authorize_url
  # Do authentication
  url = URI.parse(auth_url)
  Net::HTTP.start(url.host, url.port) do |http|
    form = {'lang' => 'en'}      # Force English
    # Get input form
    res = http.get url.request_uri, form
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
    inputs.each do |inp|
      key = inp.attributes['name']
      keyS = key.gsub /^[^\[]+\[([^\]]+)\]/, '\1'
      if params.has_key?(key)
        form[key] = params[key]
      elsif params.has_key?(keyS)
        form[key] = params[keyS]
      else
        form[key] = inp.attributes['value']
      end
    end
    form.delete('cancel')     # This one will DENY access to the user
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
    # Get the PIN
    doc = Hpricot(res.body)
    pin = (doc/"#oauth_pin").inner_html.strip
    access_token = request_token.get_access_token(:oauth_verifier => pin)
    # Post a Tweet TODO improve this
    res = access_token.post('/statuses/update.json', { :status => "First tweet through fooAuth"})
    res.body
  end  # http session
end
