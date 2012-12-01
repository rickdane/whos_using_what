require_relative "whos_using_what/search_client"
require_relative "whos_using_what/linkedin_client"

class WhosUsingWhat

  if __FILE__ == $PROGRAM_NAME

    client = SearchClient.new()
    #client.search("ebay.com", "ruby")

    linkedin_client = LinkedinClient.new("", "", "", "", "")

    linkedin_client.gather_company_data(0, 115, nil)

  end

end