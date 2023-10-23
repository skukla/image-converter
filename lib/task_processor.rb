#!/usr/bin/env ruby

# Task Processor - Processes image conversion, renaming, and deletion

require_relative "../utils/file_checker"
require_relative "../utils/colors"
require_relative "../utils/constants"
require_relative "screen_printer"

module TaskProcessor
  include FileChecker

  @total_images = nil
  @skipped_images = 0
  @renamed_images = 0
  @converted_images = 0

  def self.renamed_images
    @renamed_images
  end

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
    begin
      match = output.match(/(\d+) x (\d+)/)
      return match[1].to_i, match[2].to_i if match
    rescue ArgumentError => e
      ScreenPrinter.print_message(
        "#{Colors::RED}WARNING:#{Colors::RESET} #{e.message}"
      )
    end

    nil
  end

  def self.rename_image(source_image)
    new_name = File.basename(source_image, ".*").gsub(/[_]/, "-") + ".png"
    File.rename(source_image, File.join(File.dirname(source_image), new_name))

    @renamed_images += 1
  end

  def self.should_rename_image?(source_image)
    FileChecker.needs_rename?(source_image)
  end

  def self.should_convert_image?(source_image)
    supported_image = FileChecker.supported_image?(source_image)
    !FileChecker.png_file?(source_image) && supported_image
  end

  def self.convert_and_resize_image(source_image, destination_image, size)
    if size && !size.empty?
      `convert "#{source_image}" -resize #{size} "#{destination_image}"`
    else
      source_width, source_height = get_image_size(source_image)
      if source_width && source_height
        `convert "#{source_image}" -resize #{source_width}x#{source_height} "#{destination_image}"`
      elsif source_image =~ /\.(svg)$/i
        `rsvg-convert -f png -o "#{destination_image}" "#{source_image}"`
      else
        `convert "#{source_image}" "#{destination_image}"`
      end
    end

    @converted_images += 1
  end

  def self.generate_destination_image(source_image, destination_path)
    new_name = File.basename(source_image, ".*").gsub(/[_]/, "-") + ".png"
    destination_path ||= File.dirname(source_image)

    # Ensure the destination path is a full path
    destination_path = File.expand_path(destination_path)

    File.join(destination_path, new_name)
  end

  def self.delete_source_image(source_image)
    File.delete(source_image)
  end

  def self.print_rename_message(source_image, destination_image)
    ScreenPrinter.print_message(
      "Renaming #{Colors::CYAN}#{File.basename(source_image)}#{Colors::RESET} to #{Colors::FUSCIA}#{File.basename(destination_image)}#{Colors::RESET}..."
    )
  end

  def self.print_conversion_message(source_image, destination_image)
    ScreenPrinter.print_message(
      "Converting #{Colors::CYAN}#{File.basename(source_image)}#{Colors::RESET} to #{Colors::FUSCIA}#{File.basename(destination_image)}#{Colors::RESET}..."
    )
  end

  def self.print_skip_message(source_image)
    ScreenPrinter.print_message(
      "#{Colors::YELLOW}Skipping #{File.basename(source_image)}#{Colors::RESET}..."
    )
  end

  def self.print_final_progress
    if @converted_images == 0 && @renamed_images == 0 && @skipped_images == 0
      return ScreenPrinter.print_message("No images were processed.")
    end

    if @skipped_images == @total_images || @renamed_images == @total_images
      ScreenPrinter.print_progress(@total_images, @total_images)
    end
  end

  def self.process_tasks(source_path:, destination_path:, size:)
    image_files = get_image_files(source_path)

    if image_files.empty?
      ScreenPrinter.print_message("No images found to convert.")
      exit
    end

    total_images = get_total_images(source_path)
    ScreenPrinter.start(total_images)

    image_files.each_with_index do |source_image, index|
      destination_image =
        generate_destination_image(source_image, destination_path)

      unless should_convert_image?(source_image) ||
               should_rename_image?(source_image)
        @skipped_images += 1
        print_skip_message(source_image)
        next
      end

      if should_rename_image?(source_image) &&
           !should_convert_image?(source_image)
        print_rename_message(source_image, destination_image)
        rename_image(source_image)
      end

      if should_convert_image?(source_image)
        print_conversion_message(source_image, destination_image)
        convert_and_resize_image(source_image, destination_image, size)
        delete_source_image(source_image)
      end

      ScreenPrinter.print_progress(index + 1, total_images)
    end

    if @converted_images == 0 && @renamed_images == 0 && @skipped_images == 0
      ScreenPrinter.print_message("No images were processed.")
    end

    print_final_progress
  end
end
