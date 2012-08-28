#!/usr/bin/env ruby
# Sensor platform simulator
#

current_dir = File.expand_path(File.dirname(__FILE__))

require 'eventmachine'
require 'trollop'
require 'yaml'
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
  numbers = sim["number"].to_i
  (0...numbers).each_with_index do |number, index|
    platform = Hash.new
    platform["slug"] = sim["slug"] + index.to_s
    platform["time"] = sim["time"]
    platform["jitter"] = sim["jitter"]
    platform["sensors"] = sim["sensors"]
    platforms.push(platform_sim.new(platform))
  end
end
puts "Done."

puts "Press \'q\' to stop simulation."
output_dir = config["data_dump"]

# Save STTY state
stty_save = `stty -g`

# Simulate Platforms...
EM.run do
  if getchar == "q"
    EM.stop
  end

  platforms.each do |platform|
    EM.add_periodic_timer(platform["time"].to_i) do
      sleep(rand(platform["jitter"]))
      run_sim(platform)
    end

    if getchar == "q"
      EM.stop
    end
  end 
end

# Restore STTY state
system("stty #{stty_save}")