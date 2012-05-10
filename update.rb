#!/usr/bin/env ruby

# Copy files from ~, using underscores in place of leading dots

require 'fileutils'

IGNORED = %w(.git .gitignore README.md update.rb . ..)

def copy_dir dir
  if dir == ""
    dir = "*"
  else
    dir = File.join(dir, "*")
  end

  files = Dir[dir].reject {|f| IGNORED.include? f}

  files.each {|file|
    if File.directory? file
      copy_dir file
    else
      f = File.expand_path "~/#{file.sub /^_/, '.'}"

      puts "Skipping #{file}, doesn't exist!" && next unless File.exists? f

      FileUtils.cp(f, file)
    end
  }
end

copy_dir("")
