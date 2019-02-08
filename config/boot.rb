ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
# TODO: upgrade ruby to 2.6.0 and enable the bootsnap back again
#require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
