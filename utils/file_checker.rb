#!/usr/bin/env ruby

# utils/file_checker.rb - Utility module for checking file formats

module FileChecker
  SUPPORTED_IMAGE_EXTENSIONS = %w[jpg jpeg png gif svg]

  def self.supported_image?(image_path)
    supported_extensions = SUPPORTED_IMAGE_EXTENSIONS.map(&:downcase)
    ext = File.extname(image_path).delete(".").downcase
    supported_extensions.include?(ext)
  end

  def self.png_file?(image_path)
    ext = File.extname(image_path).delete(".").downcase
    ext == "png"
  end

  def self.needs_rename?(image_path)
    File.basename(image_path).include?("_")
  end
end
