ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'rack/test'

require_relative '../app.rb'

RSpec.configure do |config|
end
