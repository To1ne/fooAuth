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
      # keep method for later use
      @method = request.request_method.downcase.to_sym
      # get API URL from path
      url = URI.parse(request.fullpath[1..-1]) # cut off leading '/'
      @page = url.request_uri
      @site = url.site

      # oAuth key and secret # TODO with or without foo_?
      @consumer_key = params['foo_consumer_key']
      @consumer_secret = params['foo_consumer_secret']

      # delete 'splat' param created by the '/*' rule
      params.delete 'splat'
      # keep params to forward
      @params = params.reject { |key,val| key.match(/^foo_/) }

      # get basic authentication credentials
      auth = Rack::Auth::Basic::Request.new(request.env)
      (auth.provided? && auth.basic? && auth.credentials) || throw(:halt, [401, "Not no authentication credentials given\n"])
      (@username, @password) = auth.credentials

      # callback url
      @callback = "http://#{request.host_with_port}/auth"
    end
    def get_response
      # get authentication url
      consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, {:site => @site})
      request_token = consumer.get_request_token(:oauth_callback => @callback)
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
        when Net::HTTPSuccess
          # TODO parse html and do <meta http-equiv="refresh" content=... /> redirection
        when Net::HTTPRedirection
          # TODO not sure what to do here
        else
          res.error!
        end
      end  # http session
    end # def
  end # class
end # helpers

post '/' do
  "Hello" # TODO get content from README.org or .md...
end

get '/auth/*/' do
  # TODO
  puts "request:"
  pp request
  puts "params:"
  pp params
  puts "session:"
  pp session
  #access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
  # do the request
  #res = access_token.request(@method, @page, @params)
end

post '/*' do
  foo = FooAuth.new(params, request)
  foo.get_response
end

get  '/*' do
  foo = FooAuth.new(params, request)
  foo.get_response
end
