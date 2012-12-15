require "../lib/whos_using_what/linkedin_client"
require "../lib/whos_using_what/search_client"
require 'yaml'


describe LinkedinClient do

  it "retrieves companies that might use ruby" do
    @li_config = YAML.load_file('config.yaml')
    @start = 0
    linkedin_client = LinkedinClient.new(@li_config["linkedin.api_key"], @li_config["linkedin.api_secret"], @li_config["linkedin.user_token"], @li_config["linkedin.user_secret"], "http://linkedin.com")
    search_client = SearchClient.new

    results = linkedin_client.gather_company_data(@start, nil, nil)

    query = "ruby"

    results.each do |key, value|
      uses = search_client.search(query, value["websiteUrl"])
      if (uses)
        puts value["universalName"] << " probably uses " << query
      else
      end

      sleep 1
    end
  end

end