#!/usr/bin/env ruby

# main.rb -- Application entry point

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

@start_time = Time.now

TaskProcessor.process_tasks(
  source_path: options[:source_path],
  destination_path: options[:destination_path],
  size: options[:size]
)

end_time = Time.now
elapsed_time_seconds = end_time - @start_time
elapsed_time_formatted = Time.at(elapsed_time_seconds).utc.strftime("%H:%M:%S")

ScreenPrinter.print_newline

ScreenPrinter.print_summary(
  total_images,
  TaskProcessor.renamed_images,
  TaskProcessor.converted_images,
  TaskProcessor.skipped_images,
  elapsed_time_formatted
)
