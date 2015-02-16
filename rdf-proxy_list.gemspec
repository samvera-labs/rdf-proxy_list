# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.version     = File.read('VERSION').chomp
  s.date        = File.mtime('VERSION').strftime('%Y-%m-%d')

  s.name        = 'rdf-proxy_list'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Jeremy Friesen', 'Tom Johnson']
  s.homepage    = 'https://github.com/projecthydra-labs/rdf-proxy_list'
  s.email       = 'tom@dp.la'
  s.summary     = %q{An RDF.rb implementation of OAI-ORE style ordered lists with proxy nodes.}
  s.description = %q{Implements ordered, doubly-linked lists with ore:Proxy and iana: ordering terms.}
  s.license     = "Apache 2.0"
  s.required_ruby_version     = '>= 1.9.3'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")

  s.add_dependency('rdf', '~> 1.1')
  s.add_development_dependency('rspec')
  s.add_development_dependency('pry')

end
