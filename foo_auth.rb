#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'oauth'
require 'net/http'
require 'hpricot'

helpers do
  class URI::Generic
    def site # the site without path and everything following
      loc = URI::Generic.new(@scheme, @userinfo, @host, @port, @registry, nil, nil, nil, nil)
      loc.to_s
    end
  end

  class FooAuth
    def initialize(params, request)
      pp "Creating new FooAuth object"
      @method = request.request_method.downcase.to_sym
      pp "method: " + @method.to_s
      # get API URL from path
      url = URI.parse(request.fullpath[1..-1]) # cut off leading '/'
      pp "url: " + url.to_s
      @page = url.request_uri
      pp "page: " + @page
      @site = url.site
      pp "site: " + @site

      # oAuth key and secret # TODO with or without foo_?
      @consumer_key = params['foo_consumer_key']
      @consumer_secret = params['foo_consumer_secret']

      # delete 'splat' created by the '/*' rule
      params.delete 'splat'
      # keep params to forward
      @params = params.reject { |key,val| key.match(/^foo_/) }

      pp "request: "
      pp request

      # get basic authentication credentials
      auth = Rack::Auth::Basic::Request.new(request.env)
      (auth.provided? && auth.basic? && auth.credentials) || throw(:halt, [401, "Not no authorization credentials given\n"])
      (@username, @password) = auth.credentials

      # Callback url
      @callback = "http://#{request.host_with_port}/auth"
    end
    def get_response
      pp "Create consumer"
      # get authentication url
      consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, {:site => @site})
      pp consumer
      pp "Request token"
      site_token = consumer.get_request_token(:oauth_callback => @callback)
      pp site_token
      auth_url = request_token.authorize_url
      # do authentication
      url = URI.parse(auth_url)
      # TODO I don't think this session is needed
      Net::HTTP.start(url.host, url.port) do |http|
        form = {'lang' => 'en'}      # force English
        # get input form
        res = http.get url.request_uri, form
        # check response
        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          # ok
        else
          res.error!
        end
        # parse the form
        doc = Hpricot(res.body)
        inputs = doc.search('input')
        # fill in form
        inputs.each do |inp|
          key = inp.attributes['name']
          #keyS = key.gsub(/^[^\[]+\[([^\]]+)\]/, '\1') # parse 'field' from 'session[field]' (used on twitter.com)
          # TODO find better way to let the user pass credentials
          if key.match(/\buser(?:name)?/) # end word boundary \b does not work on twitter.com
            form[key] = @username
          elsif key.match(/\bpass(?:word)?\b/)
            form[key] = @password
          else # keep the hidden fiels (oAuth sizzle)
            form[key] = inp.attributes['value']
          end
        end
        form.delete('cancel')     # this one will DENY access to the user
        # TODO can we just use basic auth?
        # does not work url.userinfo = "#{@username}:#{@password}"
        # post form
        res = Net::HTTP.post_form url, form
        # check response
        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          # ok
        else
          res.error!
        end
        # TODO remove
        File.open('body.html', 'w') { |f| f.write(res.body) }
        # get the PIN # TODO maybe the callback way is better
        doc = Hpricot(res.body)
        pin = (doc/"#oauth_pin").inner_html.strip
        access_token = request_token.get_access_token(:oauth_verifier => pin)
        # do the request
        #res = access_token.post(@page, @params)
        res = access_token.request(@method, @page, @params)
        res.body
      end  # http session
    end # def
  end # class
end # helpers

post '/' do
  "Hello" # TODO get content from README.org or .md...
end

get '/auth' do # TODO improve path + add user given path
  # TODO
end

post '/*' do
  foo = FooAuth.new(params, request)
  #foo.get_response
end

get  '/*' do
  foo = FooAuth.new(params, request)
  #foo.get_response
end
