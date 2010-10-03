require 'rubygems'
require 'oauth'
require 'sinatra'
#require 'net/http'

post '/' do
  site = params['site']
  consumer=OAuth::Consumer.new('wh5EMIRW7CCWYGZbAVMDA', 'vCXJ81ARTjWJm6i8qw9EzfzZp6gWPR9CNUUNuh3Gh8', {:site => site})
  request_token=consumer.get_request_token
  auth_url = request_token.authorize_url
  puts auth_url
  url = URI.parse(auth_url)
  Net::HTTP.start(url.host, url.port) { |http|
    res = http.get url.path
    puts res
  }
end
