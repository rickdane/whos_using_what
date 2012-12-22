$:.unshift(File.expand_path('../../lib/whos_using_what/data_gatherers', __FILE__))
$:.unshift(File.expand_path('../../lib/whos_using_what/data_searchers', __FILE__))
$:.unshift(File.expand_path('../../lib/whos_using_what/api_clients', __FILE__))
$:.unshift(File.expand_path('../../lib/whos_using_what/no_sql', __FILE__))
$:.unshift(File.expand_path('../../lib/whos_using_what/util', __FILE__))
$:.unshift(File.expand_path('../../lib/whos_using_what/logging', __FILE__))
$:.unshift(File.expand_path('../../lib/whos_using_what', __FILE__))

require 'geo_tagger'
require 'companies_searcher'
require 'gather_companies'
require 'logger_factory'


if __FILE__ == $PROGRAM_NAME

  log = LoggerFactory.get_default_logger

  geo_tagger = GeoTagger.new log
  gather_companies = GatherCompanies.new
  companies_searcher = CompaniesSearcher.new geo_tagger


  #todo run in different threads
  #gather_companies.load_companies_to_db 700, 6820

  log.info "begin geo-tagging tests"

  geo_tagger.load_geolocations_into_db

  #geo_tagger.update_companies_with_latitude_longitude

  #near = companies_searcher.geospatial_search -122.4099154, 37.8059887

  near = companies_searcher.zip_code_search "95688"

  puts near

end