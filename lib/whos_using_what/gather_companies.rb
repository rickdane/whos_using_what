#meant to be able to be used as long-running process to save company data to DB

require '../whos_using_what/no_sql/mongo_helper'
require_relative 'linkedin_client'

class GatherCompanies


  if __FILE__ == $PROGRAM_NAME

    @linkedin_tech_industry_codes = "4,132,6,96,113";

    @@mongo_client = MongoHelper.get_mongo_connection

    @@companies_coll = @@mongo_client['companies']

    @li_config = YAML.load_file(File.expand_path("../../whos_using_what/config/linkedin.env", __FILE__))

    ENV["mongo.host"]= @li_config["mongo.host"]

    @@linkedin_client = LinkedinClient.new @li_config["api_key"], @li_config["api_secret"], @li_config["user_token"], @li_config["user_secret"], @li_config["url"]

    cnt = 1
    num_iterations = 200
    cur_start_position = 220
    increment = 20

    while cnt <= num_iterations do
      puts cur_start_position.to_s

      resp = @@linkedin_client.query_companies ({
          "start" => cur_start_position.to_s << "&count=" << increment.to_s,
          "facet=industry" => @linkedin_tech_industry_codes,
          "locations:(address:(postal-code))" => "95688"
      })
      docs = resp['companies'].values[3]
      docs.each do |doc|
        @@companies_coll.insert(doc)
      end


      cur_start_position = cur_start_position + increment

      cnt = cnt + 1

      sleep_seconds = rand(1-17)
      puts "sleeping for: " << sleep_seconds.to_s << " seconds"
      sleep(sleep_seconds)

    end


  end


end