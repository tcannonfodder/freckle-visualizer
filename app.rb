require 'rubygems'; require 'bundler'; Bundler.require
require 'ruby-debug'
require "sinatra/reloader" if development?
require 'json'

home_dir = File.expand_path('..', __FILE__)
require home_dir + '/config'
require home_dir + '/api_client'


get '/' do
  client = APIClient.new(PAT)
  entries = client.get_entries
  logger.debug entries

  content_type :json
  entries.to_json
end