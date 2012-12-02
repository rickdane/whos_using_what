require 'oauth'
require 'json'
require_relative 'config_module'

class LinkedinClient

  #the company industry codes to search for, see: https://developer.linkedin.com/documents/industry-codes
  attr :access_token, true
  attr :companyUrls

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


  def self.parsePersonResult(result)

    result['people']['values'].each do |person|
      puts person['firstName'] + " " + person['lastName']
    end
  end


  def parseCompanyResults(result)
    results = Hash.new
    result['companies']['values'].each do |company|
      results[company['universalName']] = company['websiteUrl']
    end
    return results
  end


  #test method, remove eventually
  def apiCallLinkedin
    url = "http://api.linkedin.com/v1/company-search:(companies:(universal-name,website-url,locations:(address:(city,state))),facets,num-results)?facet=location,us:84&facet=industry," <<
        @linkedin_tech_industry_codes <<
        "&format=json" <<
        "&start=" << @start <<
        "&count=" << @numberResults

    json = @access_token.get(url)

    JSON.parse(json.body)

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
      url = "http://api.linkedin.com/v1/company-search:(companies:(universal-name,website-url,locations:(address:(city,state))),facets,num-results)?facet=location,us:84&facet=industry," <<
          industry_codes <<
          "&format=json" <<
          "&start=" << (start * @max_results + 1).to_s <<
          "&count=" << @max_results.to_s


      json = @access_token.get(url)

      tmp_results = parseCompanyResults(JSON.parse(json.body))

      tmp_results.each do |key, value|
        results[key] = value
      end

      cnt = cnt + 1
    end
    results
  end

end