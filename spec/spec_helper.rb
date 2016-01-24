ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'rack/test'
require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'
require 'capybara/poltergeist'

require_relative '../app.rb'

RSpec.configure do |config|
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app)
  end
  Capybara.app = Sinatra::Application.new
  Capybara.javascript_driver = :poltergeist
  Capybara.default_driver = :poltergeist
  Capybara.server do |app,port|
    require 'rack/handler/thin'
    Rack::Handler::Thin.run(app, :Host => "127.0.0.1", :Port => port)
  end
end

