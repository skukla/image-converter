# error_handler.rb - Handle errors and check for ImageMagick

# Define a module for handling errors and checking for ImageMagick
module ErrorHandler
  def self.check_libraries(source_format)
    required_commands = ["convert"] # 'convert' is part of ImageMagick

    # Check if the required commands are available
    required_commands.each do |command|
      unless system("which #{command} > /dev/null 2>&1")
        puts "Error: #{command} (from ImageMagick) is not installed. Please install ImageMagick before running the program."
        exit(1)
      end
    end

    # Additional checks based on source format if needed
    if source_format == "png"
      puts "Warning: Source format is PNG. Skipping conversion."
    end
  end
end
