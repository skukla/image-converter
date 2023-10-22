# screen_printer.rb - Handle screen output and custom progress bar

module ScreenPrinter
  def self.print_progress(current, total)
    progress = (current.to_f / total) * 100
    bar_length = 50
    completed_length = (progress / 2).to_i
    remaining_length = bar_length - completed_length

    # Create a progress bar string with '=' and spaces
    bar = "[" + "=" * completed_length + " " * remaining_length + "]"

    # Print the progress bar and newline
    puts "Progress: #{bar} #{progress.to_i}%"
  end

  def self.start(total)
    print_progress(0, total)
  end

  def self.print_message(message)
    # Print the message with a newline
    puts message
  end

  def self.print_newline
    # Print a newline
    puts
  end
end
