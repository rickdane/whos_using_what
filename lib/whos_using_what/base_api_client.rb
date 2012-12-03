class BaseApiClient

   def prepare_params_from_map_helper (base_url, params_map)

     base_url = base_url << "?"
     params_map.each do |key, value|
       base_url = base_url << "&" << key << "=" << value
     end
     base_url

   end

end