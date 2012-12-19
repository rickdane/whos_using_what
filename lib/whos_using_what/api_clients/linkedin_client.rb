require 'oauth'
require 'json'
require 'base_api_client'

class LinkedinClient < BaseApiClient


  @@json_indicator = "format=json"


  def initialize(api_key, api_secret, user_token, user_secret, url)
    super()

    consumer = OAuth::Consumer.new(api_key, api_secret, {:site => url})

    @access_token = OAuth::AccessToken.new(consumer, user_token, user_secret)

  end


  def query_companies params

    @@base_url = "http://api.linkedin.com/v1/"

    base_url = @@base_url <<
        "company-search:(
        companies:(
        id,
        name,
        universal-name,
        website-url,
        industries,
        logo-url,
        employee-count-range,
        locations
      )
    )"

    json_api_call_helper(base_url, params)

  end


  def json_api_call_helper (base_url, params)

    url = prepare_params_from_map_helper(base_url, params)

    #remove white spaces, for ease in reading queries, they may have white spaces / line breaks
    url = url.gsub(/\s+/, "")

    puts url

    json = @access_token.get(url << "&" << @@json_indicator)

    JSON.parse(json.body)

  end


end