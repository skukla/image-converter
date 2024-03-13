#!/usr/bin/env ruby

# utils/file_checker.rb - Utility module for checking file formats

module FileChecker

  def self.ext(image_path)
    File.extname(image_path).delete(".").downcase
  end
  
  def self.image_exists?(image_path)
    File.exist?(image_path)
  end
  
  def self.supported_image?(image_path)
    Constants::SUPPORTED_IMAGE_EXTENSIONS.include?(ext(image_path))
  end

  def self.needs_rename?(image_path)
    File.basename(image_path).include?("_") || File.basename(image_path).match(/[A-Z]/)
  end
end
