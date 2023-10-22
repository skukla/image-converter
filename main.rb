# main.rb - Entry point for the image converter program

require_relative "arguments_collector"
require_relative "error_handler"
require_relative "screen_printer"
require_relative "task_processor"

# Collect and validate command-line arguments
options = ArgumentsCollector.collect

# Check if ImageMagick is installed
ErrorHandler.check_libraries("imagemagick")

# Count the total number of images to be processed
total_images = TaskProcessor.count_images(options[:source_path])

# Initialize the screen printer
printer = ScreenPrinter

# Process the image conversion, resizing, renaming, and deletion tasks
TaskProcessor.process_tasks(
  source_path: options[:source_path],
  destination_path: options[:destination_path],
  size: options[:size],
  printer: printer
)

# Print a completion message
printer.print_newline
printer.print_message(
  "Image conversion and processing completed for #{total_images} images."
)
