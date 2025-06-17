#!/usr/bin/env ruby

# lib/error_handler.rb - Handle errors and check for required utilities

module ErrorHandler
  # Mapping of commands to their corresponding homebrew packages
  HOMEBREW_PACKAGES = {
    "convert" => "imagemagick",
    "magick" => "imagemagick",
    "rsvg-convert" => "librsvg",
    "potrace" => "potrace",
    "autotrace" => "autotrace",
    "inkscape" => "inkscape"
  }.freeze

  def self.check_requirements(requirements)
    missing_libraries = []
    missing_commands = []
    missing_gems = []

    requirements.each do |requirement, components|
      components.each do |component|
        case requirement
        when "library"
          unless system("which #{component} > /dev/null 2>&1")
            missing_libraries << component
          end
        when "command"
          unless system("which #{component} > /dev/null 2>&1")
            missing_commands << component
          end
        when "gem"
          begin
            gem component
          rescue LoadError
            missing_gems << component
          end
        end
      end
    end

    if missing_libraries.any?
      puts "\n❌ Error: The following required libraries are not installed:"
      missing_libraries.each do |lib|
        package = HOMEBREW_PACKAGES[lib]
        if package
          puts "   • #{lib} (install with: brew install #{package})"
        else
          puts "   • #{lib}"
        end
      end
      puts "\nPlease install the missing packages and try again."
      exit(1)
    end

    if missing_commands.any?
      puts "\n❌ Error: The following required commands are not installed:"
      missing_commands.each do |cmd|
        package = HOMEBREW_PACKAGES[cmd]
        if package
          puts "   • #{cmd} (install with: brew install #{package})"
        else
          puts "   • #{cmd}"
        end
      end
      puts "\nPlease install the missing packages and try again."
      exit(1)
    end

    if missing_gems.any?
      puts "\n❌ Error: The following required gems are not installed:"
      missing_gems.each { |gem| puts "   • #{gem} (install with: gem install #{gem})" }
      puts "\nPlease install the missing gems and try again."
      exit(1)
    end
  end

  def self.check_svg_conversion_requirements
    svg_tools = ["potrace", "autotrace"]
    available_tools = svg_tools.select { |tool| system("which #{tool} > /dev/null 2>&1") }
    
    if available_tools.empty?
      puts "\n⚠️  Warning: No SVG tracing tools found for raster-to-vector conversion."
      puts "   For better SVG conversion quality, consider installing:"
      svg_tools.each do |tool|
        package = HOMEBREW_PACKAGES[tool]
        puts "   • #{tool} (brew install #{package})" if package
      end
      puts "\n   Falling back to embedded raster images in SVG format."
    end
  end
end
