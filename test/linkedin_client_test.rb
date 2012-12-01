require_relative "../lib/whos_using_what/linkedin_client"
require 'yaml'
require '../lib/whos_using_what/search_client'

class LinkedinClientTest

  if __FILE__ == $PROGRAM_NAME

    config = YAML.load_file('config.yaml')

    search_client = SearchClient.new
    linkedin_client = LinkedinClient.new(config["linkedin.api_key"], config["linkedin.api_secret"], config["linkedin.user_token"], config["linkedin.user_secret"], "http://linkedin.com")

    results = linkedin_client.gather_company_data(0, 115, nil)

    max = 5
    it = 1
    results.each do |key, value|
      puts search_client.search("ruby",value)
      sleep 1
      if (it >= max)
        break
      end
      it = it + 1
    end

  end

end