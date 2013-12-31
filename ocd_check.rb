#!/usr/bin/ruby
# encoding: UTF-8

# ocd_check.rb: Obsessive Cookbook Disorder Check: Simple app to check the cookbooks in your
#               local repo against the versions on the Chef community site.  It will return
#               false positives if your cookbooks have the same name as community cookbook site
#               cookbooks.

# load the libs
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'ocdconfig'
require 'cookbook'

# allow printing in colors without loading a gem.
# ripped from stack overflow
def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def red(text)
  colorize(text, 31)
end

def green(text)
  colorize(text, 32)
end

puts 'OCDCheck - Obsessive Cookbook Disorder Check'
puts ''

# load app configs
conf = OCDConfig.new
conf_opts = conf.return_config

# check to see if the repo path exists.  Exit if it doesn't
if File.exists?(conf_opts['repo_path'])
  puts "Checking cookbooks at #{conf_opts['repo_path']}"
else
  puts "The Chef Repository path of #{conf_opts['repo_path']} could not be found"
  puts 'Either pass the repo path using the command line arguments or define it in a ocdcheck.yml file'
  exit 1
end

# check the cookbooks
cookbooks = CookbookCheck.new(conf_opts)
puts 'Requesting cookbook versions from the Opscode Community site. This may take several minutes.'
cookbooks.check_versions

# parse the results
results = cookbooks.return_results
results.each_pair do |cb, hash|
  if hash['local'] == '-1'
    puts "#{cb}: " + red('Could not load version from local metadata.rb file')
  elsif hash['remote'].nil?
    puts "#{cb}: Could not find the cookbook on the community site"
  elsif hash['local'] == hash['remote']
    puts "#{cb}: " + green("Version #{hash['local']} matches upstream")
  else
    puts "#{cb}: " + red("Local version #{hash['local']} doesn't match community site version #{hash['remote']}")
  end
end
