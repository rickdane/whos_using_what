class CompaniesSearcher

  def initialize

    @mongo_client = MongoHelper.get_mongo_connection
    @companies_coll = @mongo_client['companies']
    @coords_coll = @mongo_client['coordinates']

    @geo_tagger = GeoTagger.new

  end

  def geospatial_search lon, lat

    near = @companies_coll.find({"loc" => {"$near" => [lat, lon]}})


  end

  def zip_code_search zip_code
    zip_doc = @coords_coll.find_one({:zip => zip_code})
    if zip_doc == nil

      #todo consider making a method in GeoTagger class to do this instead of using closure directly here
      #todo need to figure out how to call this from other class
      closure = @geo_tagger.process_zip_closure zip_code

      closure.call

    end
    zip_doc = @coords_coll.find_one({:zip => zip_code})

    if zip_doc == nil
      return nil
    end

    results = geospatial_search zip_doc["loc"]["lon"], zip_doc["loc"]["lat"]
    results.to_a
  end

end