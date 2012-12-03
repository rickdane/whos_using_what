require 'oauth'
require 'json'
require_relative 'config_module'
require_relative 'base_api_client'

class LinkedinClient < BaseApiClient

  #the company industry codes to search for, see: https://developer.linkedin.com/documents/industry-codes
  attr :access_token, true
  attr :companyUrls
  @@json_indicator = "format=json"

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

  def add_json_to_map(key_field_name, raw_json_map, output_map)
    raw_json_map.each do |value|
      output_map[value[key_field_name]] = value
    end
  end


  #todo this should be put into module for re-use
  def json_api_call_helper (base_url, params)
    url = prepare_params_from_map_helper(base_url, params)
    json = @access_token.get(url << "&" << @@json_indicator)

    JSON.parse(json.body)
  end

  # this method searches for people from a specified company for a specific job type
  def people_search_for_company (location_code, title, company_name)

    params = Hash.new
    params["facet=location"] = "us:" <<location_code
    params["current-company"]= "true"
    params["title"]=title
    params["company-name"] = company_name

    base_url = "http://api.linkedin.com/v1/people-search:(people,facets)"

    puts json_api_call_helper(base_url, params)['people']['values']

  end


  def gather_company_data(start, number_to_collect, industry_codes)

    if number_to_collect == nil
      number_to_collect = 20
    end

    request_num = number_to_collect
    cnt = 0
    div = number_to_collect / @max_results
    if (div <1)
      div = 1
    end

    results = Hash.new

    if (industry_codes == nil)
      industry_codes = @linkedin_tech_industry_codes
    end

    while cnt < div do
      base_url = "http://api.linkedin.com/v1/company-search:(companies:(universal-name,id,website-url,locations:(address:(city,state))),facets,num-results)"

      params = Hash.new
      params["start"] = (start * @max_results + 1).to_s
      params["count"] =  @max_results.to_s
      params["facet=location"] =   "us:84"
      params["facet=industry"]  = industry_codes

      raw_json_map = json_api_call_helper(base_url, params)['companies']['values']
      add_json_to_map("universalName", raw_json_map, results)

      cnt = cnt + 1
    end
    results
  end

end