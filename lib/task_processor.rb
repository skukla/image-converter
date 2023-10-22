# Task Processor

require_relative "../utils/file_checker"
require_relative "../utils/colors"
require_relative "../utils/constants"
require_relative "screen_printer"

module TaskProcessor
  include FileChecker

  @total_images = nil
  @skipped_images = 0
  @converted_images = 0

  def self.converted_images
    @converted_images
  end

  def self.skipped_images
    @skipped_images
  end

  def self.count_images(source_path)
    get_total_images(source_path)
  end

  def self.get_total_images(source_path)
    @total_images ||= get_image_files(source_path).length
  end

  def self.get_image_files(directory)
    supported_extensions = Constants::SUPPORTED_IMAGE_EXTENSIONS.join(",")
    Dir.glob(
      File.join(directory, "**", "*.{#{supported_extensions}}"),
      File::FNM_CASEFOLD
    )
  end

  def self.get_image_size(file_path)
    output = `file "#{file_path}" 2>&1`
    match = output.match(/(\d+) x (\d+)/)
    return match[1].to_i, match[2].to_i if match

    nil
  end

  def self.convert_and_resize_image(source_image, destination_image, size)
    source_width, source_height = get_image_size(source_image)

    if size
      `convert "#{source_image}" -resize #{size} "#{destination_image}" 2>/dev/null`
    else
      if source_image =~ /\.(svg)$/i
        `rsvg-convert -f png -o "#{destination_image}" "#{source_image}" 2>/dev/null`
      else
        `convert "#{source_image}" "#{destination_image}" 2>/dev/null`
      end
    end

    @converted_images += 1
  end

  def self.should_convert_image?(source_image)
    FileChecker.supported_image?(source_image) &&
      !FileChecker.png_file?(source_image)
  end

  def self.generate_destination_image(source_image, destination_path)
    new_name = File.basename(source_image, ".*").gsub(/[_]/, "-") + ".png"
    File.join(destination_path || File.dirname(source_image), new_name)
  end

  def self.delete_source_image(source_image)
    File.delete(source_image)
  end

  def self.print_conversion_message(source_image, destination_image)
    message =
      "Converting #{Colors::CYAN}#{File.basename(source_image)}#{Colors::RESET} to #{Colors::FUSCIA}#{File.basename(destination_image)}#{Colors::RESET}..."
    ScreenPrinter.print_message(message)
  end

  def self.print_skip_message(source_image)
    message =
      "#{Colors::YELLOW}Skipping #{File.basename(source_image)}#{Colors::RESET}..."
    ScreenPrinter.print_message(message)
  end

  def self.print_progress_if_all_skipped(total_images, printer)
    if @skipped_images == total_images
      printer.print_progress(total_images, total_images)
    end
  end

  def self.process_tasks(source_path:, destination_path:, size:, printer:)
    image_files = get_image_files(source_path)
    total_images = get_total_images(source_path)
    printer.start(total_images)

    image_files.each_with_index do |source_image, index|
      if should_convert_image?(source_image)
        destination_image =
          generate_destination_image(source_image, destination_path)
        print_conversion_message(source_image, destination_image)
        convert_and_resize_image(source_image, destination_image, size)
        delete_source_image(source_image)
        printer.print_progress(index + 1, total_images)
      else
        print_skip_message(source_image)
        @skipped_images += 1
      end
    end

    print_progress_if_all_skipped(total_images, printer)
  end
end
