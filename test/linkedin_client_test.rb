require_relative "../lib/whos_using_what/linkedin_client"
require 'yaml'
require '../lib/whos_using_what/search_client'

class LinkedinClientTest

  @@start = 2
  #in increments of 20 only, default is 20
  @@number_of_results = 20

  def self.test_get_companies (linkedin_client, search_client)
    results = linkedin_client.gather_company_data(@@start, nil, nil)

    query = "ruby"

    results.each do |key, value|
      uses = search_client.search(query, value["url"])
      if (uses)
        puts value["url"] << " probably uses " << query
      else
      end

      sleep 1
    end
  end


  def self.test_get_people (linkedin_client)
    linkedin_client.people_search_for_company(nil, "84")
  end

  if __FILE__ == $PROGRAM_NAME

    config = YAML.load_file('config.yaml')

    search_client = SearchClient.new
    linkedin_client = LinkedinClient.new(config["linkedin.api_key"], config["linkedin.api_secret"], config["linkedin.user_token"], config["linkedin.user_secret"], "http://linkedin.com")

    #test_get_companies(linkedin_client, search_client)

    test_get_people(linkedin_client)


  end


end