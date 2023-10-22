# arguments_collector.rb - Collect and validate command-line arguments

# Define a module for collecting and validating command-line arguments
module ArgumentsCollector
  require "optparse"

  # Define a method to collect and validate command-line arguments
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

  # Define a method to validate arguments
  def self.validate_arguments(options)
    # Validate source path (required)
    unless options.key?(:source_path)
      puts "Source path is required. Use '-h' for help."
      exit(1)
    end

    # You can add additional validation logic here for destination and size arguments if needed
  end
end
