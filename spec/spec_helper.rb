require 'bundler/setup'
Bundler.setup

require 'rdf'

RSpec.configure do |config|
  config.color = true
  config.tty = true

  config.formatter = :progress
end
