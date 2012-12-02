require_relative "../lib/whos_using_what/linkedin_client"
require 'yaml'
require '../lib/whos_using_what/search_client'

class LinkedinClientTest

  @@start = 2
  #in increments of 20 only, default is 20
  @@number_of_results = 20

  if __FILE__ == $PROGRAM_NAME

    config = YAML.load_file('config.yaml')

    search_client = SearchClient.new
    linkedin_client = LinkedinClient.new(config["linkedin.api_key"], config["linkedin.api_secret"], config["linkedin.user_token"], config["linkedin.user_secret"], "http://linkedin.com")

    results = linkedin_client.gather_company_data(@@start, nil, nil)

    query = "ruby"

    results.each do |key, site|
      uses = search_client.search("ruby", value)
      if uses
        puts site << " probably uses " << query
      else

      end

      sleep 1
    end

  end

end