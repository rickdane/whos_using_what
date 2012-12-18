require 'lib/whos_using_what/data_gatherers/geo_tagger'
require 'lib/whos_using_what/data_searchers/companies_searcher'


if __FILE__ == $PROGRAM_NAME

  geo_tagger = GeoTagger.new

  companies_searcher = CompaniesSearcher.new

#geoTagger.load_geolocations_into_db

#geoTagger.update_companies_with_latitude_longitude

#near = companies_searcher.geospatial_search -122.4099154, 37.8059887

  near = companies_searcher.zip_code_search "95688"

  puts near

end