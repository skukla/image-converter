#!/usr/bin/env ruby

# Task Processor - Processes image conversion, renaming, and deletion

require_relative "../utils/file_checker"
require_relative "../utils/colors"
require_relative "../utils/constants"
require_relative "screen_printer"

module TaskProcessor
  include FileChecker

  @default_format = "png"
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

  def self.get_image_files(source)
    supported_extensions = Constants::SUPPORTED_IMAGE_EXTENSIONS.join(",")

    return [File.join(source)] unless File.directory?(source)

    Dir.glob(
      File.join(source, "**", "*.{#{supported_extensions}}"),
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

  def self.set_image_name(source_image)
    File.basename(source_image, ".*").gsub(/_/, "-").downcase +
      ".#{FileChecker.ext(source_image)}"
  end

  def self.rename_image(source_image)
    File.rename(
      source_image,
      File.join(File.dirname(source_image), set_image_name(source_image))
    )

    @renamed_images += 1
  end

  def self.should_rename_image?(source_image)
    FileChecker.needs_rename?(source_image)
  end

  def self.set_format(format)
    result = @default_format
    result = format unless format.nil?
    result
  end

  def self.should_convert_image?(source_image, format)
    FileChecker.image_exists?(source_image) &&
      FileChecker.supported_image?(source_image) &&
      set_format(format) != FileChecker.ext(source_image)
  end

  def self.convert_and_resize_image(
    source_image,
    destination_image,
    format,
    size
  )
    success = false
    
    # Special handling for PNG to SVG conversion to preserve full image
    if set_format(format) == "svg" && source_image =~ /\.(png|jpg|jpeg|gif|bmp|tiff)$/i
      success = convert_raster_to_svg(source_image, destination_image, size)
    elsif size && !size.empty?
      success = system("magick \"#{source_image}\" -resize #{size} \"#{destination_image}\"")
    else
      source_width, source_height = get_image_size(source_image)
      if source_width && source_height
        success = system("magick \"#{source_image}\" -resize #{source_width}x#{source_height} \"#{destination_image}\"")
      elsif source_image =~ /\.(svg)$/i
        success = system("rsvg-convert -f #{set_format(format)} -o \"#{destination_image}\" \"#{source_image}\"")
        unless success
          ScreenPrinter.print_message(
            "#{Colors::RED}ERROR:#{Colors::RESET} SVG conversion failed. Ensure librsvg is installed: brew install librsvg"
          )
          return false
        end
      else
        success = system("magick \"#{source_image}\" \"#{destination_image}\"")
      end
    end

    unless success
      ScreenPrinter.print_message(
        "#{Colors::RED}ERROR:#{Colors::RESET} Failed to convert #{File.basename(source_image)}. Check that ImageMagick is installed: brew install imagemagick"
      )
      return false
    end

    @converted_images += 1
    true
  end

  def self.convert_raster_to_svg(source_image, destination_image, size)
    # Get image dimensions
    source_width, source_height = get_image_size(source_image)
    
    # Convert to base64 for embedding
    require 'base64'
    image_data = File.read(source_image)
    base64_data = Base64.strict_encode64(image_data)
    
    # Determine MIME type
    mime_type = case File.extname(source_image).downcase
                when '.png' then 'image/png'
                when '.jpg', '.jpeg' then 'image/jpeg'
                when '.gif' then 'image/gif'
                when '.bmp' then 'image/bmp'
                when '.tiff', '.tif' then 'image/tiff'
                else 'image/png'
                end
    
    # Apply resize if specified
    if size && !size.empty?
      if size.include?('x')
        width, height = size.split('x').map(&:to_i)
      else
        # If only one dimension is given, maintain aspect ratio
        width = size.to_i
        height = (source_height * width / source_width).to_i
      end
    else
      width = source_width
      height = source_height
    end
    
    # Create SVG with embedded image
    svg_content = <<~SVG
      <?xml version="1.0" encoding="UTF-8"?>
      <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" 
           width="#{width}" height="#{height}" viewBox="0 0 #{width} #{height}">
        <image x="0" y="0" width="#{width}" height="#{height}" 
               xlink:href="data:#{mime_type};base64,#{base64_data}"/>
      </svg>
    SVG
    
    # Write SVG file
    File.write(destination_image, svg_content)
  end

  def self.generate_destination_image(source_image, destination_path, format)
    destination_path ||= File.dirname(source_image)

    File.join(
      destination_path,
      File.basename(set_image_name(source_image), ".*") +
        ".#{set_format(format)}"
    )
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

  def self.process_tasks(source_path:, destination_path:, format:, size:)
    image_files = get_image_files(source_path)

    if image_files.empty?
      ScreenPrinter.print_message("No images found to convert.")
      exit
    end

    total_images = get_total_images(source_path)
    ScreenPrinter.start(total_images)

    image_files.each_with_index do |source_image, index|
      unless should_convert_image?(source_image, format) ||
               should_rename_image?(source_image)
        @skipped_images += 1
        print_skip_message(source_image)
        next
      end

      destination_image =
        generate_destination_image(source_image, destination_path, format)

      if should_rename_image?(source_image)
        print_rename_message(source_image, destination_image)
        rename_image(source_image)
      end

      if should_convert_image?(source_image, format)
        print_conversion_message(source_image, destination_image)
        convert_and_resize_image(source_image, destination_image, format, size)
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
