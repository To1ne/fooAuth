#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'oauth'
require 'net/http'
require 'mechanize'

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

      # Start mechanize
      agent = Mechanize.new
      agent.follow_meta_refresh = true       # make sure we are redirected to callback url

      # get the login page
      page = agent.get(url, {'lang' => 'en'})      # force English
      form = page.forms.first     # just assume first (and only) # TODO make it failsafe
      # fill in username and password
      form.fields.each do |key, val|
        if key.name.match(/\buser(?:name)?/) # end word boundary \b does not work on twitter.com
          form[key.name] = @username
        elsif key.name.match(/\bpass(?:word)?\b/)
          form[key.name] = @password
        end
      end
      # send the form
      page = agent.submit form, form.button_with(:name => nil)
      # the callback will just return the oauth parameters as body
      tokens = page.body.split
      # get access token
      access_token = request_token.get_access_token(:oauth_token => tokens.first, :oauth_verifier => tokens.last )
      # and finally do the request
      res = access_token.request(@method, @page, @params)
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        # ok
      else
        res.error!
      end
      res.body
    end # def
  end # class
end # helpers

get '/' do
  "Hello" # TODO get content from README.org or .md...
end

post '/' do
  "Hello" # TODO get content from README.org or .md...
end

get '/auth' do # TODO I don't really like this method?
  # Authentication OK, just return oauth parameters
  params[:oauth_token] + ' ' + params[:oauth_verifier]
end

post '/*' do # TODO regex matching
  foo = FooAuth.new(params, request)
  foo.get_response
end

get  '/*' do # TODO regex matching
  foo = FooAuth.new(params, request)
  foo.get_response
end
