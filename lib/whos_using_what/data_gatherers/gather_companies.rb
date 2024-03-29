require_relative "../base"

#meant to be able to be used as long-running process to save company data to DB
class GatherCompanies < Base

  require 'mongo_helper'
  require 'linkedin_client'
  require 'indeed_api_client'

  def initialize

    @indeed_api_client = IndeedApiClient.new

    @@mongo_client = MongoHelper.get_mongo_connection

    @@companies_coll = @@mongo_client['companies']

    @li_config = YAML.load_file(File.expand_path("../../config/linkedin.env", __FILE__))

    @@linkedin_client = LinkedinClient.new @li_config["api_key"], @li_config["api_secret"], @li_config["user_token"], @li_config["user_secret"], @li_config["url"]


  end

  def load_companies_from_indeed

    num_iterations = 20
    increment = 20
    cnt = 15

    while cnt <= num_iterations do

      keyword = "ruby"
      city_state = "pleasant hill, ca"

      json_resp = @indeed_api_client.perform_search keyword, city_state, increment, (increment * (cnt-1)) + 1

      json_resp['results'].each do |job|

        if  @@companies_coll.find_one({'name' => job['company']}) != nil
          next
        end

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
      cnt += cnt
    end

  end

  def load_companies_to_db num_iterations, cur_start_position, facet_location_code

    company_size_codes = "C,D,E,F,G,H,I"
    increment = 10
    cnt = 1

    while cnt <= num_iterations do
      puts cur_start_position.to_s

      params = {
          "start" => cur_start_position.to_s
      }

      resp = @@linkedin_client.query_companies facet_location_code, company_size_codes, params
      docs = resp['companies'].values[3]
      if docs != nil
        docs.each do |doc|
          puts doc
          @@companies_coll.insert(doc)
        end
      end

      cur_start_position = cur_start_position + increment

      cnt = cnt + 1

      sleep_seconds = rand(3-9)
      puts "sleeping for: " << sleep_seconds.to_s << " seconds"
      sleep(sleep_seconds)

    end
  end

end