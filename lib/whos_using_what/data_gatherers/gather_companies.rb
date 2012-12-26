require_relative "../base"

#meant to be able to be used as long-running process to save company data to DB
class GatherCompanies < Base

  require 'mongo_helper'
  require 'linkedin_client'
  require 'indeed_api_client'

  def initialize

    @linkedin_tech_industry_codes = "4,132,6,96,113";

    @indeed_api_client = IndeedApiClient.new

    @@mongo_client = MongoHelper.get_mongo_connection

    @@companies_coll = @@mongo_client['companies']

    @li_config = YAML.load_file(File.expand_path("../../config/linkedin.env", __FILE__))

    @@linkedin_client = LinkedinClient.new @li_config["api_key"], @li_config["api_secret"], @li_config["user_token"], @li_config["user_secret"], @li_config["url"]


  end

  def load_companies_from_indeed

    keyword = "ruby"
    city_state = "pleasant hill, ca"

    json_resp = @indeed_api_client.perform_search keyword, city_state

    json_resp['results'].each do |job|

      company = {}

      company['locations'] = {
          values: [
              {
                  address: {
                      city: job['city'],
                      state: job['state'],
                      country: job['country']
                  }
              }
          ]
      }
      company['name']= job['company']
      company['languages'] =
          {
              keyword.to_s => job['url']
          }


      @@companies_coll.insert company

    end

  end

  def load_companies_to_db num_iterations, cur_start_position, facet_location_code

    increment = 20
    cnt = 1

    while cnt <= num_iterations do
      puts cur_start_position.to_s

      resp = @@linkedin_client.query_companies ({
          "start" => cur_start_position.to_s << "&count=" << increment.to_s,
          "facet=industry" => @linkedin_tech_industry_codes,
          "facet=location" => facet_location_code
      })
      docs = resp['companies'].values[3]
      if docs != nil
        docs.each do |doc|
          puts doc
          @@companies_coll.insert(doc)
        end
      end

      cur_start_position = cur_start_position + increment

      cnt = cnt + 1

      sleep_seconds = rand(1-35)
      puts "sleeping for: " << sleep_seconds.to_s << " seconds"
      sleep(sleep_seconds)

    end
  end

end