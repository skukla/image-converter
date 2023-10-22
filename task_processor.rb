# task_processor.rb - Process image conversion, resizing, renaming, and deletion

require "fileutils"

module TaskProcessor
  def self.process_tasks(source_path:, destination_path:, size:, printer:)
    # Get a list of image files in the source directory and its subdirectories
    image_files = get_image_files(source_path)

    total_images = image_files.length

    # Start the progress bar with the total number of images to be processed
    printer.start(total_images)

    # Process each image
    image_files.each_with_index do |source_image, index|
      # Determine the destination file path (convert to PNG format)
      destination_image = source_image.sub(/\.jpg|\.jpeg|\.gif|\.svg/i, ".png")

      # Print the current image being processed
      printer.print_message("Processing #{File.basename(source_image)}...")

      # Convert to PNG (if not already PNG) and overwrite the source image
      convert_to_png(source_image, destination_image)

      # Resize (if size is provided) and overwrite the source image
      resize_image(destination_image, size) if size

      # Replace dashes and underscores with underscores in the new name
      new_name = File.basename(destination_image).gsub(/[-_]+/, "-")
      new_path = File.join(File.dirname(source_image), new_name)

      # Delete the original source image
      File.delete(source_image)

      # Rename the image (if needed)
      File.rename(destination_image, new_path) if destination_image != new_path

      # Display the updated progress
      printer.print_progress(index + 1, total_images)
    end
  end

  # Count the total number of images in the source directory and its subdirectories
  def self.count_images(source_path)
    image_files = get_image_files(source_path)
    image_files.length
  end

  private

  def self.get_image_files(directory)
    # Retrieve a list of image files (e.g., jpg, jpeg, png, gif, svg)
    # in the given directory and its subdirectories
    Dir.glob(
      File.join(directory, "**", "*.{jpg,jpeg,png,gif,svg}"),
      File::FNM_CASEFOLD
    )
  end

  def self.convert_to_png(source_image, destination_image)
    if source_image =~ /\.(svg)$/i
      # If it's an SVG file, specify rendering options to retain quality
      `convert "#{source_image}" -resize 100% -density 300 -background none -flatten "#{destination_image}"`
    else
      # For non-SVG files, convert to PNG without specifying a size
      `convert "#{source_image}" "#{destination_image}"`
    end
  end

  def self.resize_image(source_image, destination_image, size)
    if size
      # Resize the image to the specified size
      `convert "#{source_image}" -resize #{size} "#{destination_image}"`
    end
  end
end
