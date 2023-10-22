# lib/screen_printer.rb - Print output to the screen

require_relative "../utils/colors"

module ScreenPrinter
  def self.print_progress(current, total)
    progress = (current.to_f / total) * 100
    bar_length = 50
    completed_length = (progress / 2).to_i
    remaining_length = bar_length - completed_length

    bar =
      "#{Colors::BOLD_WHITE}[" + "=" * completed_length +
        " " * remaining_length + "]"

    percentage = "#{Colors::GREEN}#{progress.to_i}%#{Colors::RESET}"

    puts "#{Colors::BOLD_WHITE}Progress: #{bar} #{percentage}"
  end

  def self.start(total)
    print_progress(0, total)
  end

  def self.print_message(message)
    puts message
  end

  def self.print_newline
    puts
  end

  def self.print_summary(
    total_images,
    converted_images,
    skipped_images,
    elapsed_time
  )
    puts "#{Colors::BOLD_WHITE}Summary:#{Colors::RESET}"
    puts "Total Images: #{Colors::BOLD_WHITE}#{total_images}#{Colors::RESET}"
    puts "Converted Images: #{Colors::GREEN}#{converted_images}#{Colors::RESET}"
    puts "Skipped Images: #{Colors::YELLOW}#{skipped_images}#{Colors::RESET}"
    puts "Elapsed Time: #{Colors::FUSCIA}#{elapsed_time.round(2)} seconds#{Colors::RESET}"
  end
end
