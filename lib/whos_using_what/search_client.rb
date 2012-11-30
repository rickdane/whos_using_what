require "uri"
require "rest-client"

class SearchClient

  attr :results

  def initialize()


    @negativeMatchUrlPatterns = Array.new.push("google.com").push("youtube.com")

    @positiveMatchUrlPatterns = Array.new.push("http")


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

  end

  def search(site, query)

    url = "https://www.google.com/search?hl=en&as_q=" << query << "&as_epq=&as_oq=&as_eq=&as_nlo=&as_nhi=&lr=&cr=&as_qdr=all&as_sitesearch=" << site << "&as_occt=any&safe=off&tbs=&as_filetype=&as_rights="

    rawHtml = RestClient.get(url)

    extractUrls(rawHtml, site)

  end

end