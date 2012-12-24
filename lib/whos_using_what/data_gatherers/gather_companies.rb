require_relative "../base"

require 'mongo_helper'
require 'linkedin_client'

#meant to be able to be used as long-running process to save company data to DB
class GatherCompanies < Base

  def initialize

    @linkedin_tech_industry_codes = "4,132,6,96,113";

    @@mongo_client = MongoHelper.get_mongo_connection

    @@companies_coll = @@mongo_client['companies']

    @li_config = YAML.load_file(File.expand_path("../../config/linkedin.env", __FILE__))

    @@linkedin_client = LinkedinClient.new @li_config["api_key"], @li_config["api_secret"], @li_config["user_token"], @li_config["user_secret"], @li_config["url"]


  end

  def load_companies_to_db num_iterations, cur_start_position

    increment = 20
    cnt = 1

    while cnt <= num_iterations do
      puts cur_start_position.to_s

      resp = @@linkedin_client.query_companies ({
          "start" => cur_start_position.to_s << "&count=" << increment.to_s,
          "facet=industry" => @linkedin_tech_industry_codes,
          "locations:(address:(postal-code))" => "95688"
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