require 'oauth'
require 'json'

class LinkedinClient

  #the company industry codes to search for, see: https://developer.linkedin.com/documents/industry-codes
  attr :access_token, true
  attr :companyUrls


  def initialize(api_key, api_secret, user_token, user_secret, url)

    @industryCodes = "4,132,6,96,113";
    @numberResults = "5"
    @start = "15"
    @companyUrls = Hash.new

    consumer = OAuth::Consumer.new(api_key, api_secret, {:site => url})

    @access_token = OAuth::AccessToken.new(consumer, user_token, user_secret)


  end


  def self.parsePersonResult(result)

    result['people']['values'].each do |person|
      puts person['firstName'] + " " + person['lastName']
    end
  end

  def parseCompanyResult(result)
    result['companies']['values'].each do |company|
      @companyUrls[company['universalName']] = company['websiteUrl']
    end

  end


  def apiCallLinkedin
    #url = "http://api.linkedin.com/v1/people-search:(people:(headline,first-name,last-name,positions,location:(name)),num-results)?title=software&current-title=true&facet=location%2Cus%3A84&format=json&count=500"
    url = "http://api.linkedin.com/v1/company-search:(companies:(universal-name,website-url,locations:(address:(city,state))),facets,num-results)?facet=location,us:84&facet=industry," <<
        @industryCodes <<
        "&format=json" <<
        "&start=" << @start <<
        "&count=" << @numberResults

    json = @access_token.get(url)

    JSON.parse(json.body)

  end


end