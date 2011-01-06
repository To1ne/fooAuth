#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'oauth'
require 'net/http'
require 'hpricot'

helpers do
  class FooAuth
    def initialize(params, request)
      # TODO globals?
      # Get API URL from path
      splat = URI.parse(params[:splat].first).normalize
      @page = splat.path
      splat.path = ''
      @site = splat.to_s
      pp @site
      params.delete 'splat'

      # oAuth key and secret
      @consumer_key = params['foo_consumer_key']
      @consumer_secret = params['foo_consumer_secret']

      # All other parameters are just forwarded
      @params = params.reject { |key,val| key.match(/^foo_/) }

      # Get basic authentication credentials
      auth = Rack::Auth::Basic::Request.new(request.env)
      (auth.provided? && auth.basic? && auth.credentials) || throw # TODO error?
      (@username, @password) = auth.credentials
    end
    def post
      # Get authentication url
      consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, {:site => @request, :exclude_callback => 1 })
      site_token = consumer.get_request_token
      auth_url = request_token.authorize_url
      # Do authentication
      url = URI.parse(auth_url)
      # TODO I don't think this session is needed
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
          #keyS = key.gsub(/^[^\[]+\[([^\]]+)\]/, '\1') # parse 'field' from 'session[field]' (used on twitter.com)
          # TODO find better way to let the user pass credentials
          if key.match(/\buser(?:name)?/) # End word boundary \b does not work on twitter.com
            form[key] = @username
          elsif key.match(/\bpass(?:word)?\b/)
            form[key] = @password
          else # Keep the hidden fiels (oAuth sizzle)
            form[key] = inp.attributes['value']
          end
        end
        form.delete('cancel')     # This one will DENY access to the user
        # TODO can we just use basic auth?
        # Does not work url.userinfo = "#{@username}:#{@password}"
        # Post form
        res = Net::HTTP.post_form url, form
        # Check response
        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          # OK
        else
          res.error!
        end
        # TODO remove
        File.open('body.html', 'w') { |f| f.write(res.body) }
        # Get the PIN # TODO maybe the callback way is better
        doc = Hpricot(res.body)
        pin = (doc/"#oauth_pin").inner_html.strip
        access_token = request_token.get_access_token(:oauth_verifier => pin)
        # Post a Tweet # TODO improve this
        # TODO POST/GET res = access_token.post(@page, @params)
        res = access_token.get(@page)
        res.body
      end  # http session
    end # def
  end # class
end # helpers

post '/' do
  "Hello" # TODO get content from README.org or .md...
end

post '/*' do
  foo = FooAuth.new(params, request)
  foo.post
end

