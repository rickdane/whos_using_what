require '../../whos_using_what/no_sql/mongo_helper'
require "rest-client"

class GeoTagger

  @@mongo_client = MongoHelper.get_mongo_connection
  @@companies_coll = @@mongo_client['companies']
  @@coords_coll = @@mongo_client['coordinates']
  @@key = ""


  #doc_key = nil && doc=nil to return the end value instead of to add it to the doc
  def self.safe_extract keys_arr, map, doc_key, doc

    iter = 1
    val = ""
    keys_arr.each do |key|
      val = map[key]
      if !val
        return
      end
      if (iter == keys_arr.length)
        if doc
          doc[doc_key] = val
        end
      end
      iter = iter + 1
      map = val
    end
    val
  end

  def self.api_get_google_location_data zip_code

    params = "q=" << zip_code
    "&output=json"
    "&key=" << @@key


    @@geo_code_api_url_base = "http://maps.google.com/maps/geo?"

    begin
      rawHtml = RestClient.get(@@geo_code_api_url_base << params)
    rescue Exception => e
      puts e
    end

    json_resp = JSON.parse(rawHtml.body)

    resp_map = nil
    begin
      resp_map = json_resp["Placemark"][0]
    rescue

    end

    if !resp_map
      return nil
    end
    resp_map
  end

  def self.get_coords_from_google_location_resp resp_map

    keys_arr1 = ["Point", "coordinates", 0]
    keys_arr2 = ["Point", "coordinates", 1]
    part1 = safe_extract keys_arr1, resp_map, nil, nil
    part2 = safe_extract keys_arr2, resp_map, nil, nil

    arr = [part1, part2]

  end

  def self.process_zip_closure zip_code
    lambda {

      resp_map = api_get_google_location_data zip_code

      doc = {}


      doc[:zip] = zip_code

      coords = get_coords_from_google_location_resp resp_map
      if coords[0] && coords[1]
        doc[:loc] = {"lon" => coords[0], "lat" => coords[1]}
      end


      keys_arr = ["AddressDetails", "Country", "AdministrativeArea", "Locality", "LocalityName"]
      safe_extract keys_arr, resp_map, :city, doc

      keys_arr = ["AddressDetails", "Country", "AdministrativeArea", "AdministrativeAreaName"]
      safe_extract keys_arr, resp_map, :state, doc

      keys_arr = ["AddressDetails", "Country", "CountryNameCode"]
      safe_extract keys_arr, resp_map, :country, doc


      if (doc.size > 1 && doc[:country] == "US")
        coll = @@coords_coll.find(zip: zip_code).to_a
      end

      if coll && coll.size < 1


        @@coords_coll.insert(doc)

      end
    }

  end

  def self.zip_acceptance_predicate zip_code

    if !zip_code
      return false
    end

    accept = true

    if !zip_code.start_with? ("9")
      accept = false
    end

    accept

  end

  def self.load_geolocations_into_db

    @companies_coll.find().to_a.each do |company|

      if !company
        next
      end


      keys_arr = ['locations', 'values']
      locations = safe_extract keys_arr, company, :nil, nil

      if !locations
        next
      end
      locations.each do |location|

        zip_code = location['address']['postalCode']

        #strip off anything past 5 characters, as we only want main part of zip code
        if !zip_code || zip_code.size < 5
          next
        end

        zip_code = zip_code[0...5]

        if (zip_acceptance_predicate (zip_code))


          begin
            closure = GeoTagger.process_zip_closure zip_code

            closure.call
          rescue Exception => e
            puts zip_code

          end
        end
      end
    end
  end

  def self.update_companies_with_latitude_longitude

    @companies_coll.find().to_a.each do |company|


      locations = safe_extract ["locations", "values"], company, nil, nil

      if locations

        locations.each do |location|

          zip = safe_extract ["address", "postalCode"], location, nil, nil

          if zip

            coords = @@coordinates_coll.find_one({:zip => zip})
            if coords != nil

              company["loc"] = coords["loc"]

              @companies_coll.update({"_id" => company["_id"]}, company)

            end
          end
        end
      end
    end
  end

  def self.geospatial_search lon, lat

    near = @@companies_coll.find({"loc" => {"$near" => [lat, lon]}})

  end

  def self.zip_code_search zip_code
    zip_doc = @@coords_coll.find_one({:zip_code => zip_code})
    if zip_doc == nil

      closure = GeoTagger.process_zip_closure zip_code

      closure.call

    end
    zip_doc = @@coords_coll.find_one({:zip_code => zip_code})

    if zip_doc == nil
      return nil
    end

    results = geospatial_search zip_doc["loc"]["lon"], zip_doc["loc"]["lat"]
    results.to_a
  end

  if __FILE__ == $PROGRAM_NAME


=begin
    @@mongo_client = MongoHelper.get_mongo_connection
    @@companies_coll = @@mongo_client['companies']
    @@coords_coll = @@mongo_client['coordinates']
=end

    @@coords_coll.remove({"loc" => nil})

    @@coords_coll.ensure_index([["loc", Mongo::GEO2D]])
    @@companies_coll.ensure_index([["loc", Mongo::GEO2D]])

    #load_geolocations_into_db

    #update_companies_with_latitude_longitude

    #near = geospatial_search -122.4099154, 37.8059887

    near = GeoTagger.zip_code_search "95688"

    s = ""

  end


end