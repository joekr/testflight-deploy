$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rubygems'
require 'rest_client'
require 'scanf.rb'
require 'lib/fssm'
require 'yaml'

config = YAML.load_file("config.yaml")

END_POINT = config["END_POINT"]
TEAM_TOKEN = config["TEAM_TOKEN"]
API_TOKEN = config["API_TOKEN"]
DIST_LIST = config["DIST_LIST"]
REPLACE = config["REPLACE"]
NOTIFY = config["NOTIFY"]
NOTES = config["NOTES"]

# Code from https://github.com/lukeredpath/betabuilder/blob/master/lib/beta_builder/deployment_strategies/testflight.rb
# Copyright (c) 2011 Luke Redpath

def uploadFile(fileName)

    puts "Uploading '#{fileName}' to TestFlight ... "

    currentTime = Time.new
    
    payload = {
        :api_token          => API_TOKEN,
        :team_token         => TEAM_TOKEN,
        :file               => File.new(fileName.to_s, 'rb'),
        :notes              => NOTES + " ("+currentTime.inspect+")",
        :distribution_lists => DIST_LIST,
        :notify             => NOTIFY
    }
    
    begin
        response = RestClient.post(END_POINT, payload, :accept => :json)
        rescue => e
        response = e.response
    end
    
    if (response.code == 201) || (response.code == 200)
        puts "Upload complete."
        else
        puts "Upload failed. (#{response})"
    end
    
end

FSSM.monitor('.', '**/*.ipa') do
  update { |b, r| uploadFile(r) }
  create { |b, r| uploadFile(r) }
end

