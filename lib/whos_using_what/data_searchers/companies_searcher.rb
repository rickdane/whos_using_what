require_relative "../base"

class CompaniesSearcher < Base

  #geo_tagger = instance of GeoTagger
  def initialize geo_tagger

    @mongo_client = MongoHelper.get_mongo_connection
    @companies_coll = @mongo_client['companies']
    @coords_coll = @mongo_client['coordinates']

    @geo_tagger = geo_tagger

  end

  def geospatial_search lon, lat

    near = @companies_coll.find({"loc" => {"$near" => [lat, lon]}})


  end

  #find people from a company, based off the user's network and connections
  def find_people_for_company linkedin_client, company_name, location

    puts linkedin_client.query_people_from_company company_name, location

  end

  def zip_code_search zip_code

    zip_doc = @coords_coll.find_one({:zip => zip_code})
    if zip_doc == nil

      @geo_tagger.insert_new_zip_entry zip_code

    end
    zip_doc = @coords_coll.find_one({:zip => zip_code})

    if zip_doc == nil
      return nil
    end

    results = geospatial_search zip_doc["loc"]["lon"], zip_doc["loc"]["lat"]
    results.to_a
  end

end