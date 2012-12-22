require 'map_data_extraction_util'

class GoogleLocationsClient


  def initialize

    #todo pull this from config file if this becomes needed
    @google_api_key = ""

  end


  def api_get_google_location_data zip_code

    params = "q=" << zip_code
    "&output=json"
    "&key=" << @google_api_key


    @geo_code_api_url_base = "http://maps.google.com/maps/geo?"

    begin
      rawHtml = RestClient.get(@geo_code_api_url_base << params)
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


  def get_coords_from_google_location_resp_helper resp_map

    keys_arr1 = ["Point", "coordinates", 0]
    keys_arr2 = ["Point", "coordinates", 1]

    part1 = MapDataExtractionUtil.safe_extract_helper keys_arr1, resp_map, nil, nil
    part2 = MapDataExtractionUtil.safe_extract_helper keys_arr2, resp_map, nil, nil

    arr = [part1, part2]

  end

end