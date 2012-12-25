require_relative "../base"

class GeoTagger < Base

  require 'mongo_helper'
  require 'map_data_extraction_util'
  require 'google_locations_client'

  require "rest-client"

  def initialize log
    @log = log
    @mongo_client = MongoHelper.get_mongo_connection
    @companies_coll = @mongo_client['companies']
    @coords_coll = @mongo_client['coordinates']

    @locations_client = GoogleLocationsClient.new

    #todo this code should possibly be moved somewhere else for clarity / encapsulation
    @coords_coll.remove({"loc" => nil})

    @coords_coll.ensure_index([["loc", Mongo::GEO2D]])
    @companies_coll.ensure_index([["loc", Mongo::GEO2D]])

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

  def insert_new_zip_entry zip_code

    if (zip_acceptance_predicate (zip_code))

      begin
        #todo figure how to do this now that we are using instance variables instead of class variables
        process_zip_closure = lambda {

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

        process_zip_closure.call
      rescue Exception => e
        puts e.message
        puts e.backtrace

      end
    end

  end


  def load_geolocations_into_db

    companies = @companies_coll.find()
    companies_arr = companies.to_a
    companies_arr.each do |company|

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

        insert_new_zip_entry zip_code
      end
    end
  end

  def update_companies_with_latitude_longitude

    @log.info "beginning updating of companies with latitude and longitude data"

    @companies_coll.find().to_a.each do |company|


      locations = MapDataExtractionUtil.safe_extract_helper ["locations", "values"], company, nil, nil

      if locations

        locations.each do |location|

          zip = MapDataExtractionUtil.safe_extract_helper ["address", "postalCode"], location, nil, nil

          if zip

            coords = @coords_coll.find_one({:zip => zip})
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