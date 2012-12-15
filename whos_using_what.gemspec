require 'rake'

Gem::Specification.new do |s|
  s.name        = 'whos_using_what'
  s.version     = '0.1.5'
  s.date        = '2012-12-02'
  s.summary     = "Who's Using What?"
  s.description = "What companies are using what technologies"
  s.authors     = ["Rick Dane"]
  s.email       = 'r.dane1010@gmail.com'
  s.files       = FileList['lib/**/*.rb', 'lib/whos_using_what.rb']
  s.add_dependency("oauth")
  s.add_dependency("json")
  s.add_dependency("rest-client")
  s.add_dependency("rake")
  s.add_dependency("rspec")
  s.add_dependency("uri")
  s.add_dependency("mongo")
  s.homepage    =
      'http://rubygems.org/gems/whos_using_what'
end