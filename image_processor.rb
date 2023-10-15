#!/usr/bin/env ruby

require 'optparse'
require 'pathname'
require 'fileutils'
require 'ruby-progressbar'

# Check if ImageMagick is installed
def imagemagick_installed?
  system('convert -version > /dev/null 2>&1')
  $?.success?
end

class ImageProcessor
  attr_reader :source_dir, :dest_dir, :size, :recursive

  def initialize(source_dir, dest_dir = nil, size = nil, recursive = true)
    @source_dir = Pathname.new(source_dir)
    @dest_dir = dest_dir.nil? ? @source_dir : Pathname.new(dest_dir)
    @size = size
    @recursive = recursive
  end

  def process_images
    # Recursively find all image files in the source directory and subdirectories
    image_files = if @recursive
      Dir.glob(File.join(@source_dir, '**', '*.{jpg,jpeg,png,gif,bmp,webp,avif}'), File::FNM_CASEFOLD)
    else
      [source_dir]
    end

    progress_bar = ProgressBar.create(format: '%a %e %P% %B', total: image_files.count)
    
    image_files.each do |source_file|
      extname = File.extname(source_file).downcase

      if extname == '.png'
        puts "Skipping #{source_file} (already in PNG format)"
        next
      end

      # Construct the destination file path with PNG extension
      relative_path = Pathname.new(source_file).relative_path_from(@source_dir)
      dest_file = @dest_dir.join(relative_path).sub(/\.\w+$/, '.png')

      # Create the destination directory if it doesn't exist
      FileUtils.mkdir_p(dest_file.dirname.to_s)

      # Convert the image to PNG format and resize it
      convert_command = "convert #{source_file} -format png"
      convert_command += " -resize #{@size}x#{@size}" if @size && !@size.empty?
      convert_command += " #{dest_file}"
      puts "Converting #{source_file} to #{dest_file}..."
      system(convert_command)

      # Delete the original image after successful conversion
      File.delete(source_file)

      # Update progress bar
      progress_bar.increment
    end
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: image_processor.rb [options]"

  opts.on("-sSIZE", "--size=SIZE", "Desired size of the output image (in pixels)") do |size|
    options[:size] = size
  end

  opts.on("-s", "--single IMAGE_FILE", "Process a single image file") do |image_file|
    options[:single] = image_file
  end
end.parse!

if options[:single]
  unless ARGV.size == 0
    puts "Usage: image_processor.rb -s IMAGE_FILE [-sSIZE]"
    exit 1
  end
  source_dir = options[:single]
else
  unless ARGV.size >= 1 && ARGV.size <= 2
    puts "Usage: image_processor.rb source_dir [dest_dir] [-sSIZE]"
    exit 1
  end
  source_dir = ARGV[0]
end

dest_dir = options[:single] ? nil : ARGV[1]
size = options[:size]
recursive = true unless options[:single]

processor = ImageProcessor.new(source_dir, dest_dir, size, recursive)
processor.process_images
