require_relative "../lib/whos_using_what/linkedin_client"
require 'yaml'

class LinkedinClientTest

  if __FILE__ == $PROGRAM_NAME

    config = YAML.load_file('config.yaml')

    linkedin_client = LinkedinClient.new(config["linkedin.api_key"], config["linkedin.api_secret"],config["linkedin.user_token"], config["linkedin.user_secret"], "http://linkedin.com")

    linkedin_client.gather_company_data(0, 115, nil)

  end

end