# utils/file_checker.rb - Utility module for checking file formats

module FileChecker
  SUPPORTED_IMAGE_EXTENSIONS = %w[jpg jpeg png gif svg]

  def self.supported_image?(image_path)
    supported_extensions = SUPPORTED_IMAGE_EXTENSIONS.map { |ext| ext.downcase }
    ext = File.extname(image_path).delete(".").downcase
    supported_extensions.include?(ext)
  end

  def self.png_file?(image_path)
    ext = File.extname(image_path).delete(".").downcase
    ext == "png"
  end
end
