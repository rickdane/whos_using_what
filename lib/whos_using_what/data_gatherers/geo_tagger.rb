require '../../whos_using_what/no_sql/mongo_helper'
require 'lib/util/map_data_extraction_util'

require "rest-client"

class GeoTagger

  def initialize
    @mongo_client = MongoHelper.get_mongo_connection
    @companies_coll = @mongo_client['companies']
    @coords_coll = @mongo_client['coordinates']

    @locations_client = GoogleLocationsClient.new

    #todo this code should possibly be moved somewhere else for clarity / encapsulation
    @coords_coll.remove({"loc" => nil})

    @coords_coll.ensure_index([["loc", Mongo::GEO2D]])
    @companies_coll.ensure_index([["loc", Mongo::GEO2D]])

  end


  def process_zip_closure zip_code
    lambda {

      resp_map = @locations_client.api_get_google_location_data zip_code

      doc = {}


      doc[:zip] = zip_code

      coords = @locations_client.get_coords_from_google_location_resp_helper resp_map
      if coords[0] && coords[1]
        doc[:loc] = {"lon" => coords[0], "lat" => coords[1]}
      end


      keys_arr = ["AddressDetails", "Country", "AdministrativeArea", "Locality", "LocalityName"]
      MapDataExtractionUtil.safe_extract_helper keys_arr, resp_map, :city, doc

      keys_arr = ["AddressDetails", "Country", "AdministrativeArea", "AdministrativeAreaName"]
      MapDataExtractionUtil.safe_extract_helper keys_arr, resp_map, :state, doc

      keys_arr = ["AddressDetails", "Country", "CountryNameCode"]
      MapDataExtractionUtil.safe_extract_helper keys_arr, resp_map, :country, doc


      if (doc.size > 1 && doc[:country] == "US")
        coll = @coords_coll.find(zip: zip_code).to_a
      end

      if coll && coll.size < 1


        @coords_coll.insert(doc)

      end
    }

  end


  def zip_acceptance_predicate zip_code

    if !zip_code
      return false
    end

    accept = true

    if !zip_code.start_with? ("9")
      accept = false
    end

    accept

  end


  def load_geolocations_into_db

    @companies_coll.find().to_a.each do |company|

      if !company
        next
      end


      keys_arr = ['locations', 'values']
      locations = MapDataExtractionUtil.safe_extract_helper keys_arr, company, :nil, nil

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
            #todo figure how to do this now that we are using instance variables instead of class variables
            closure = GeoTagger.process_zip_closure zip_code

            closure.call
          rescue Exception => e
            puts zip_code

          end
        end
      end
    end
  end

  def update_companies_with_latitude_longitude

    @companies_coll.find().to_a.each do |company|


      locations = MapDataExtractionUtil.safe_extract_helper ["locations", "values"], company, nil, nil

      if locations

        locations.each do |location|

          zip = MapDataExtractionUtil.safe_extract_helper ["address", "postalCode"], location, nil, nil

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

end