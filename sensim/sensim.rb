#!/usr/bin/env ruby
# Sensor platform simulator
#

current_dir = File.expand_path(File.dirname(__FILE__))

require 'eventmachine'
require 'trollop'
require 'yaml'
require 'net/http'
require 'uri'
require current_dir + '/platform_sim'
include PlatformSim

opts = Trollop::options do
  banner "Sensor Simulator"
  opt :config, "Simulation Configuration File", {:type => String, :required => true}
end

if File.exists?(opts[:config])
  config = Psych.load_file(opts[:config])
  puts "Configuration file loaded."
else
  puts "Unable to load configuration file #{opts[:config]}!  Stopping!"
  exit -1
end

platforms = Array.new

# Build platforms to simulate
puts "Building platforms..."
config["sims"].each do |sim|
  num_platforms = sim["number"].to_i
  (0...num_platforms).each_with_index do |number, index|
    platform = Hash.new
    platform["slug"] = sim["slug"] + index.to_s
    platform["time"] = sim["time"]
    platform["jitter"] = sim["jitter"]
    platform["sensors"] = sim["sensors"]
    platforms.push(Platform_sim.new(platform))
  end
end
puts "Done."

puts "Press <ctrl-c> to stop simulation."
output_dir = config["data_dump"]

# Simulate Platforms...
EM.run do
  EM.threadpool_size = 30

  EM.add_periodic_timer(1) do
    platforms.each do |platform|
      next unless platform.time_to_run
      EM.defer do
        puts "top"
        file_data = platform.run_sim
        begin
          uri = URI.parse("http://localhost:3000/csv/#{platform.slug}")
          Net::HTTP.post_form(uri, {"data" => file_data})
        rescue => e
          puts e.inspect
          puts e.backtrace
        end
        puts file_data
      end
    end
  end 
end
