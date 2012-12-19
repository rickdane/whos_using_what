class MapDataExtractionUtil


  #doc_key = nil && doc=nil to return the end value instead of to add it to the doc
  def self.safe_extract_helper keys_arr, map, doc_key, doc

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

end