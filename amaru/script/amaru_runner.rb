#!/bin/env ruby
# Run amaru's internal functions

require './config/environment.rb'
require 'data_import'
#require 'data_process'
#require 'data_graph'
#require 'data_alert'

SUB_COMMANDS = %w(import process graph alert)
global_opts = Trollop::options do
  banner "Access Amaru's internal functionality:\nImport Data\nProcess Data\nCreate Graphs\nRun Alerts"
  opt :slug, "Platform Slug", {:type => String, :required => true}
  stop_on SUB_COMMANDS
end

cmd = ARGV.shift
cmd_opts = case cmd
  when "import"
    Trollop::options do
      banner "Import Options:"
      opt :name, "Ingest data filename", {:type => String, :required => true}
      opt :type, "Ingest data import type (csv,json)", {:type => String, :required => true}
      opt :config, "Import configuration file", {:type => String, :required => false}
    end
  when "process"
    Trollop::options do
      banner "Process Options:"
      opt :name, "Process Data Field", {:type => String, :required => true}
    end
  when "graph"
    Trollop::options do
      banner "Graph Options:"
      opt :name, "Graph Name", {:type => String, :required => true}
      opt :output, "Output File Name", {:type => String, :required => true}
      opt :start, "Start Date", {:type => String, :required => true}
      opt :end, "End Date", {:type => String, :required => true}
    end
  when "alert"
    Trollop::options do
      banner "Alert Options:"
      opt :alert, "Alert Name", {:type => String, :required => true}
    end
end

#platform = Platform.where(slug: slug).first
case cmd
  when "import"
    data_import(global_opts[:slug], cmd_opts[:import], cmd_opts[:type], cmd_opts[:config])
  when "process"
    data_process(global_opts[:slug], cmd_opts[:name])
  when "graph"
    data_graph(global_opts[:slug], cmd_opts[:graph], cmd_opts[:output], cmd_opts[:start], cmd_opts[:end])
  when "alert"
    data_alert(global_opts[:slug], cmd_opts[:alert])
end

