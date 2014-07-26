#!/usr/bin/ruby
# encoding: UTF-8

# this library handles the parsing of config options from the command line and from the
# yaml config file and produces a single config object

begin
  require 'yaml'
  require 'trollop'
rescue LoadError => e
  raise "Missing gem #{e}"
end

class OCDConfig
  def initialize
    # define the cli options with trollop
    $opts = Trollop.options do
      opt :repo, 'Path to the chef repo directory'
      opt :config, 'Path to the optional configuration file', default: ['./ocd_check.yml', '~/.chef/ocd_check.yml']
    end

    @config_file = load_config_file
  end

  def return_config
    config = {}

    if @config_file
      config['blacklist'] = @config_file['blacklist']
      config['repo_path'] = $opts[:repo] ? File.expand_path($opts[:repo]) : File.expand_path(@config_file['repo'])
    else
      config['blacklist'] = []
      config['repo_path'] = $opts[:repo]
    end
    config['cookbook_path'] = File.join(config['repo_path'], 'cookbooks')

    config
  end

  private

  # load the yaml config file if it exists.
  # loop through the array of config files so that CLI override is 1st, local dir is 2nd, and ~/.chef is last
  def load_config_file
    $opts[:config].each do |config|
      if File.exist?(File.expand_path(config))
        full_path = File.expand_path(config)
        return YAML.load(File.open(full_path))
      end
    end

    # looping over the passed config files did not produce any valid files
    puts 'No ocd_check config found.  Using command line arguments only'
    nil
  end
end
