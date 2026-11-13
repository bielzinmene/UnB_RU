ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
# Bootsnap's native cache fails on Windows paths containing accented characters.
require "bootsnap/setup" unless Gem.win_platform?
