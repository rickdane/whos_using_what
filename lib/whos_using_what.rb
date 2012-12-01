require_relative "whos_using_what/search_client"


class WhosUsingWhat

  if __FILE__ == $PROGRAM_NAME

    client = SearchClient.new()
    #client.search("ebay.com", "ruby")


  end

end