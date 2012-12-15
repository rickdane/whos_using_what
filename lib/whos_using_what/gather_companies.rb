#meant to be able to be used as long-running process to save company data to DB

require '../whos_using_what/no_sql/mongo_helper'
require_relative 'linkedin_client'

class GatherCompanies


  if __FILE__ == $PROGRAM_NAME

    @@mongo_client = MongoHelper.get_mongo_connection

    @li_config = YAML.load_file(File.expand_path("../../whos_using_what/config/linkedin.env", __FILE__))
    ENV["mongo.host"]= @li_config["mongo.host"]

    @@linkedin_client = LinkedinClient.new @li_config["api_key"], @li_config["api_secret"], @li_config["user_token"], @li_config["user_secret"], @li_config["url"]

    @@linkedin_client.people_search_for_company "84", "Software Developer", "Twitter"

    # @@linkedin_client.query_companies

  end


end