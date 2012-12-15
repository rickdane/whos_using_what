require 'oauth'
require 'json'
require_relative 'config_module'
require_relative 'base_api_client'

class LinkedinClient < BaseApiClient

  #the company industry codes to search for, see: https://developer.linkedin.com/documents/industry-codes
  attr :access_token, true
  attr :companyUrls
  @@json_indicator = "format=json"
  @@default_location_code = "84"

  include ConfigModule


  def initialize(api_key, api_secret, user_token, user_secret, url)
    super()

    @numberResults = "5"
    @start = "15"

    consumer = OAuth::Consumer.new(api_key, api_secret, {:site => url})

    @access_token = OAuth::AccessToken.new(consumer, user_token, user_secret)

    #this appears to be the most that linkedin will give back per request
    @max_results = 20

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


  #todo this should be put into module for re-use
  def json_api_call_helper (base_url, params)

    url = prepare_params_from_map_helper(base_url, params)

    #remove white spaces, for ease in reading queries, they may have white spaces / line breaks
    url = url.gsub(/\s+/, "")

    puts url

    json = @access_token.get(url << "&" << @@json_indicator)

    JSON.parse(json.body)
  end


end