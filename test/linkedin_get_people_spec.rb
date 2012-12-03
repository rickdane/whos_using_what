require "../lib/whos_using_what/linkedin_client"
require 'yaml'


describe LinkedinClient do

  it "retrieves people from linkedin matching certain criteria" do
    @config = YAML.load_file('config.yaml')
    linkedin_client = LinkedinClient.new(@config["linkedin.api_key"], @config["linkedin.api_secret"], @config["linkedin.user_token"], @config["linkedin.user_secret"], "http://linkedin.com")

    puts linkedin_client.people_search_for_company( "84", "software", "sap")
  end

end