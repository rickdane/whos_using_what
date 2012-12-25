require_relative "../base"

class BaseApiClient < Base

  require "uri"
  require "rest-client"

  def arraySearch(array, rawHtml)

    rawHtml = rawHtml.downcase
    array.each do |token|
      if (rawHtml.index(token) != nil)
        return true
      end
    end
    return false
  end

  def arry_to_str_delim array, delim

    str = ""
    i = 0
    array.each do |entry|
      if i < 1
        str = entry.strip

      else
        str = str << delim << entry.strip
      end
      i += 1
    end

    str.strip
  end


  def cleanup_url url
    #clean up url
    url = url.strip
    if url["www."] != nil
      url["www."] = ""
    end
    url

  end

  def determineIfUsesTechnology(technology, rawHtml)

    isJobPage = arraySearch(@jobPageTokens, rawHtml)

    return isJobPage

  end


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