#!/usr/bin/env ruby

# lib/arguments_collector.rb - Collect and validate command-line arguments

module ArgumentsCollector
  require "optparse"

  def self.collect
    options = {}
    parser =
      OptionParser.new do |opts|
        opts.banner = "Usage: main.rb [options]"

        opts.on("-s", "--source SOURCE", "Source path (required)") do |source|
          options[:source_path] = source
        end

        opts.on(
          "-d",
          "--destination DESTINATION",
          "Destination path (optional)"
        ) { |destination| options[:destination_path] = destination }

        opts.on("-z", "--size SIZE", "Size argument (optional)") do |size|
          options[:size] = size
        end

        opts.on_tail("-h", "--help", "Show this help message") do
          puts opts
          exit
        end
      end

    begin
      parser.parse!(ARGV)
      validate_arguments(options)
    rescue OptionParser::MissingArgument, OptionParser::InvalidOption
      puts "Invalid or missing arguments. Use '-h' for help."
      exit(1)
    end

    return options
  end

  private

  def self.validate_arguments(options)
    unless options.key?(:source_path)
      puts "Error: Source path is required. Use '-h' for help."
      exit(1)
    end
  end
end
