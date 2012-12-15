#meant to be able to be used as long-running process to save company data to DB

require '../whos_using_what/no_sql/mongo_helper'
require_relative 'linkedin_client'

class GatherCompanies


  if __FILE__ == $PROGRAM_NAME

    @linkedin_tech_industry_codes = "4,132,6,96,113";

    @@mongo_client = MongoHelper.get_mongo_connection

    @li_config = YAML.load_file(File.expand_path("../../whos_using_what/config/linkedin.env", __FILE__))

    ENV["mongo.host"]= @li_config["mongo.host"]

    @@linkedin_client = LinkedinClient.new @li_config["api_key"], @li_config["api_secret"], @li_config["user_token"], @li_config["user_secret"], @li_config["url"]

    cnt = 1
    num_iterations = 5
    numresults=10
    cur_start_position = 0

    while cnt <= num_iterations do
      puts cur_start_position.to_s

      puts @@linkedin_client.query_companies ({
          "start" => cur_start_position.to_s << "&count=5",
          "facet=industry" => @linkedin_tech_industry_codes,
          "locations:(address:(postal-code))" => "95688"
      })

      cur_start_position = cnt + numresults

      cnt = cnt + 1

    end


  end


end