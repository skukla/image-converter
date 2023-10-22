# main.rb

require_relative "./lib/error_handler"

ErrorHandler.check_requirements(
  "library" => ["magick"],
  "command" => ["rsvg-convert"]
)

require_relative "./lib/screen_printer"
require_relative "./lib/arguments_collector"
require_relative "./lib/task_processor"

options = ArgumentsCollector.collect
total_images = TaskProcessor.count_images(options[:source_path])
printer = ScreenPrinter

@start_time = Time.now

TaskProcessor.process_tasks(
  source_path: options[:source_path],
  destination_path: options[:destination_path],
  size: options[:size],
  printer: printer
)

end_time = Time.now
elapsed_time = end_time - @start_time

printer.print_newline

printer.print_summary(
  total_images,
  TaskProcessor.converted_images,
  TaskProcessor.skipped_images,
  elapsed_time
)
