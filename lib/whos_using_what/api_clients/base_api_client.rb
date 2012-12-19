class BaseApiClient

  def starts_with?(string, prefix)
    prefix = prefix.to_s
    string[0, prefix.length] == prefix
  end

  def prepare_params_from_map_helper (base_url, params_map)

    iter = 1

    base_url = base_url << "?"
    params_map.each do |key, value|

      if iter != 1
        base_url = base_url << "&"
      end

      if starts_with?(key, "facet")

        base_url = base_url << key << "," << value
      else
        base_url = base_url << key << "=" << value
      end
      iter = iter + 1
    end
    base_url

  end

end