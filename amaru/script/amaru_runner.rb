#!/bin/env ruby
# Run amaru's internal functions

current_dir = File.expand_path(File.dirname(__FILE__))

require current_dir + '/../config/environment.rb'
require current_dir + '/import.rb'
require current_dir + '/process.rb'
require current_dir + '/graph.rb'
require current_dir + '/alert.rb'
require current_dir + '/system_log.rb'

include AmaruRunner

SUB_COMMANDS = %w(import process graph alert log)
global_opts = Trollop::options do
  banner "Access Amaru's internal functionality:\nimport\t-Import Data\nprocess\t-Process Data\ngraph\t-Create Graphs\nalert\t-Run Alerts\nlog\t-Log System Messages"
  stop_on SUB_COMMANDS
end

cmd = ARGV.shift
if cmd.nil?
  Trollop::die "\n\nUse one of the following sub-commands:\nimport\nprocess\ngraph\nalert\nlog\n use -h for full help\n"
  exit -1
end

cmd_opts = case cmd
  when "import"
    Trollop::options do
      banner "Import Options:"
      opt :slug, "Platform Slug", {:type => String, :required => true}
      opt :name, "Ingest data filename", {:type => String, :required => true}
      opt :type, "Ingest data import type (csv,json)", {:type => String, :required => true}
      opt :group, "Group Name", {:type => String, :required => false}
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
      opt :start, "Start Date", {:type => String, :required => false}
      opt :end, "End Date", {:type => String, :required => false}
      opt :dump, "Dump Graph to YAML File"
    end
  when "alert"
    Trollop::options do
      banner "Alert Options:"
      opt :alert, "Alert Name", {:type => String, :required => true}
    end
  when "log"
    Trollop::options do
      banner "Log System Messages Options:"
      opt :name, "Log File Name", {:type => String, :required => true}
      opt :keep, "Number of days to keep", {:type => Integer, :required => true}
      opt :delete, "Delete System Messages from database", {:default => false, :required => false}
    end
end

#platform = Platform.where(slug: slug).first
case cmd
  when "import"
    puts "Running Import:"
    AmaruRunner::data_import(cmd_opts[:group], cmd_opts[:slug], cmd_opts[:name], cmd_opts[:type], cmd_opts[:config], `pwd`)
    puts "Finished."
  when "process"
    data_process(cmd_opts[:name])
  when "graph"
    data_graph(cmd_opts[:name], cmd_opts[:output], cmd_opts[:start], cmd_opts[:end], cmd_opts[:dump])
  when "alert"
    data_alert(cmd_opts[:alert])
  when "log"
    system_log(cmd_opts[:name], cmd_opts[:keep], cmd_opts[:delete])
end
