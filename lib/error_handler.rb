#!/usr/bin/env ruby

# lib/error_handler.rb - Handle errors and check for required utilities

module ErrorHandler
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
      puts "Warning: The following required libraries are not installed:"
      missing_libraries.each { |lib| puts "- #{lib}" }
      exit(1)
    end

    if missing_commands.any?
      puts "Warning: The following required commands are not installed:"
      missing_commands.each { |cmd| puts "- #{cmd}" }
      exit(1)
    end

    if missing_gems.any?
      puts "Warning: The following required gems are not installed:"
      missing_gems.each { |gem| puts "- #{gem}" }
      exit(1)
    end
  end
end
