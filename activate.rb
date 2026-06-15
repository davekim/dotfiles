#!/usr/bin/env ruby
require 'fileutils'

working_dir = File.expand_path(File.dirname(__FILE__))
home_dir = File.expand_path("~")

DOTFILES = %w[gitconfig gitstatus.py tmux.conf zshrc].freeze

DOTFILES.each do |name|
  filename = File.join(working_dir, name)
  sym_link = File.join(home_dir, ".#{name}")

  FileUtils.rm sym_link if File.symlink?(sym_link) || File.exist?(sym_link)
  FileUtils.ln_s filename, sym_link
end
