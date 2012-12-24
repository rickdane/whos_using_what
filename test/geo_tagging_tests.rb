$:.unshift(File.expand_path('../../lib/whos_using_what/data_gatherers', __FILE__))
$:.unshift(File.expand_path('../../lib/whos_using_what/data_searchers', __FILE__))
$:.unshift(File.expand_path('../../lib/whos_using_what/logging', __FILE__))

=begin
$:.unshift(File.expand_path('../../lib/whos_using_what/api_clients', __FILE__))
$:.unshift(File.expand_path('../../lib/whos_using_what/no_sql', __FILE__))
$:.unshift(File.expand_path('../../lib/whos_using_what/util', __FILE__))

$:.unshift(File.expand_path('../../lib/whos_using_what', __FILE__))
=end

=begin
=end
require 'geo_tagger'
require 'companies_searcher'
require 'logger_factory'
require 'gather_companies'
require 'tech_ad_tagger'


if __FILE__ == $PROGRAM_NAME

  log = LoggerFactory.get_default_logger

  geo_tagger = GeoTagger.new log
  gather_companies = GatherCompanies.new
  companies_searcher = CompaniesSearcher.new geo_tagger
  tech_ad_tagger = TechAdTagger.new


  facet_location = "us:82" #Sacramento

  #todo run in different threads
  #  gather_companies.load_companies_to_db 700, 0, facet_location

  #  log.info "begin geo-tagging tests"

  #  geo_tagger.load_geolocations_into_db

  #geo_tagger.update_companies_with_latitude_longitude

  #near = companies_searcher.geospatial_search -122.4099154, 37.8059887

  #  near = companies_searcher.zip_code_search "95688"

  @programming_languages = [ "java", "ruby", "c#", "php", "python", "javascript"]

  tech_ad_tagger.tag_company_with_technologies @programming_languages

#  puts near

end