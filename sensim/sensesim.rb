#!/usr/bin/env ruby
# Sensor platform simulator
#

require 'eventmachine'
require 'trollop'
require 'yaml'

opts = Trollop::options do
  banner "Sensor Simulator"
  opt :config, "Simulation Configuration File", {:type => String, :required => true}
end

if File.exists?(opts[:config])
  config = Psych.load(opts[:config])
  puts "Configuration file loaded."
else
  puts "Unable to load configuration file #{opts[:config]}!  Stopping!"
  exit -1
end
