#!/usr/bin/ruby
# encoding: UTF-8

begin
  require 'net/http'
  require 'rubygems'
  require 'json'
rescue LoadError => e
  raise "Missing gem #{e}"
end

class CookbookCheck
  def initialize(config)
    @result = {}
    @config = config
    @local_cbs = fetch_local_cookbooks
  end

  # builds a hash where each cookbook is the key and the value is another hash containing
  # 'local' for the local version and 'remote' for the remote version.
  # Cookbooks not found on the community site will have a remote version of nil
  def check_versions
    @local_cbs.each do |cb|
      @result[cb] = {}

      @result[cb]['local'] = cb_local_lookup(cb)
      @result[cb]['remote'] = cb_remote_lookup(cb)
    end
  end

  def return_results
    @result
  end

  private

  # lookup a single local cookbooks version
  def cb_local_lookup(cb_name)
    full_path = File.expand_path("#{@config['cookbook_path']}/#{cb_name}")
    if File.exist?("#{full_path}/metadata.rb")
      version = (`grep '^version' #{full_path}/metadata.rb`)
    else
      return -1
    end
    version.split(' ').last.gsub('"', '').gsub('\'', '').chomp
  end

  # see if the cookbook is contained in the blacklist as defained in the ocdcheck.yml file
  def blacklisted?(cookbook)
    @config['blacklist'].include?(cookbook) ? true : false
  end

  # lookup a single community cookbook site cookbook version
  def cb_remote_lookup(cb_name)
    url = "https://supermarket.getchef.com/api/v1/cookbooks/#{cb_name}/versions/latest"
    resp = Net::HTTP.get_response(URI.parse(url))

    if resp.code == '404'
      return nil
    else
      par_resp = JSON.parse(resp.body)
      return par_resp['version']
    end
  end

  def fetch_local_cookbooks
    cookbooks = []
    Dir.foreach(@config['cookbook_path']) do |cookbook|
      if File.directory?(File.join(@config['cookbook_path'], cookbook))
        unless cookbook.start_with?('.') || blacklisted?(cookbook)
          cookbooks << cookbook
        end
      end
    end
    cookbooks
  end
end
