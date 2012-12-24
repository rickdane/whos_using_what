require_relative "../base"

class SearchClient   < Base

  require "uri"
  require "rest-client"

  attr :results

  def initialize()


    @negativeMatchUrlPatterns = Array.new.push("google.com").push("youtube.com")

    @positiveMatchUrlPatterns = Array.new.push("http")

    @technologiesToSearchFor = Array.new.push("ruby").push("java").push("javascript").push("python").push("c++").push("c#")

    @jobPageTokens = Array.new.push("job", "hiring", "career")

    @results = Hash.new

  end

  def extractUrls (rawInput, mustContainUrl)

    acceptedUrls = Array.new

    urls = URI.extract(rawInput)
    urls.each do |url|
      add = true
      @negativeMatchUrlPatterns.each do |token|

        if (nil != url.index(token))
          add = false
        end
      end

      @positiveMatchUrlPatterns.each do |token|

        if (nil == url.index(token) || url.index(token) > 0)
          add = false
        end
      end

      if (mustContainUrl != nil && url.index(mustContainUrl) == nil)
        add = false
      end

      if (add)
        acceptedUrls.push(url)
      end
    end
    acceptedUrls
  end


  def arraySearch(array, rawHtml)

    rawHtml = rawHtml.downcase
    array.each do |token|
      if (rawHtml.index(token) != nil)
        return true
      end
    end
    return false
  end


  def determineIfUsesTechnology(technology, rawHtml)

    isJobPage = arraySearch(@jobPageTokens, rawHtml)

    return isJobPage

  end


  def search(query, site)

    url = "https://www.google.com/search?hl=en&as_q=" << query << "&as_epq=&as_oq=&as_eq=&as_nlo=&as_nhi=&lr=&cr=&as_qdr=all&as_sitesearch=" << site << "&as_occt=any&safe=off&tbs=&as_filetype=&as_rights="

    begin
      rawHtml = RestClient.get(url)
    rescue

    end

    urls = extractUrls(rawHtml, site)

    isMatch = false

    at_least_one_nonexception_url = false

    urls.each do |cur_url|
      begin
        html = RestClient.get(cur_url)
        uses_technology = determineIfUsesTechnology(query, html)
        at_least_one_nonexception_url = true
        if (uses_technology)
          isMatch = true
          break
        end
      rescue Exception => exception
        #raise exception
      end
    end

    if (!at_least_one_nonexception_url)
      return false
    end

    return isMatch
  end

end

