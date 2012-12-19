$:.unshift(File.expand_path('../../lib/whos_using_what/data_gatherers', __FILE__))
$:.unshift(File.expand_path('../../lib/whos_using_what/data_searchers', __FILE__))
$:.unshift(File.expand_path('../../lib/whos_using_what/api_clients', __FILE__))
$:.unshift(File.expand_path('../../lib/whos_using_what/no_sql', __FILE__))
$:.unshift(File.expand_path('../../lib/whos_using_what/util', __FILE__))
$:.unshift(File.expand_path('../../lib/whos_using_what', __FILE__))

require 'geo_tagger'
require 'companies_searcher'
require 'gather_companies'


if __FILE__ == $PROGRAM_NAME

  geo_tagger = GeoTagger.new

  gather_companies = GatherCompanies.new

  gather_companies.load_companies_to_db 700, 6820

  companies_searcher = CompaniesSearcher.new

  #geo_tagger.load_geolocations_into_db

#geoTagger.update_companies_with_latitude_longitude

#near = companies_searcher.geospatial_search -122.4099154, 37.8059887

=begin
  near = companies_searcher.zip_code_search "95688"

  puts near
=end

end