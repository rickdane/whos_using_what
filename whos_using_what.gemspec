require 'rake'

Gem::Specification.new do |s|
  s.name = 'whos_using_what'
  s.version = '1.1.1'
  s.date = '2012-12-26'
  s.summary = "Who's Using What?"
  s.description = "What companies are using what technologies"
  s.authors = ["Rick Dane"]
  s.email = 'r.dane1010@gmail.com'
  s.files = FileList['lib/**/*.rb', 'lib/**/**/*.rb']
  s.add_dependency("oauth")
  s.add_dependency("json")
  s.add_dependency("rest-client")
  s.add_dependency("rake")
  s.add_dependency("rspec")
  s.add_dependency("mechanize")
  s.add_dependency("crack")
  s.add_dependency("mongo")
  s.add_dependency('watir-webdriver')
  s.add_dependency('headless')
  s.homepage =
      'http://rubygems.org/gems/whos_using_what'
end