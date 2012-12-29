require_relative 'base_api_client'

class LinkedinClient < BaseApiClient


  require 'oauth'
  require 'json'


  @@json_indicator = "format=json"
  @@base_url = "http://api.linkedin.com/v1/"
  #@linkedin_tech_industry_codes = "4,132,6,96,113,80,126,81,8,36,118,28,140";
  @@linkedin_tech_industry_codes = "80"


  def initialize(api_key, api_secret, user_token, user_secret, url)
    super()

    @consumer = OAuth::Consumer.new(api_key, api_secret, {
        :site => url,
        #  :scope => "r_basicprofile+r_emailaddress+r_network"
    })

    @consumer.options[:request_token_path] = @consumer.options[:request_token_path] << "?scope=r_fullprofile+r_emailaddress+r_network"

    @access_token = OAuth::AccessToken.new(@consumer, user_token, user_secret)

  end


  def query_companies location_code, company_size, params

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
    )?facets=industry,location,company-size" <<
    "&facet=industry," << @@linkedin_tech_industry_codes <<
        "&facet=location," << location_code <<
        "&facet=company-size,C,D,E,F,G,H,I"

    json_api_call_helper(base_url, params)

  end


  def query_people_from_company company_name, location

    company_name = company_name.gsub(/\s+/, "+")
    location = location.gsub(/\s+/, "+")

    base_url_tmp = @@base_url.clone

    url = base_url_tmp <<
        "people-search:(people:(id,first-name,last-name,public-profile-url,picture-url,headline),num-results)" <<
        "?company-name=" << company_name << "," <<
        "&location=" << location <<
        "&current-company=true"

    json_api_call_helper url, {}

  end

  def query_people_from_company_ids company_ids, title, location

    location = location.gsub(/\s+/, "+")

    base_url_tmp = @@base_url.clone

    company_id_str = ""
    i = 1
    company_ids.each do |company_id|
      delim = ""
      if i != 1
        delim = ","
      end
      company_id_str = company_id_str << delim << company_id
      i += i
    end

    url = base_url_tmp <<
        "people-search:(people:(id,first-name,last-name,public-profile-url,picture-url,headline),num-results)" <<
        "?facets=location,current-company" <<
        "&facet=location," << location <<
        "&facet=current-company," << company_id_str
    "&current-title=" << title

    json_api_call_helper url, {}, true

  end


  def json_api_call_helper (base_url, params, skip_params = false)

    url = base_url.clone
    if !skip_params
      url = BaseApiClient.prepare_params_from_map_helper(base_url, params)
    end

    #remove white spaces, for ease in reading queries, they may have white spaces / line breaks
    url = url.gsub(/\s+/, "")

    puts url

    json = @access_token.get(url << "&" << @@json_indicator)

    JSON.parse(json.body)

  end


end