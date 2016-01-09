require File.expand_path '../test_helper.rb', __FILE__

class TestApp < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root_response_ok
    get '/'
    assert last_response.ok?
  end

  def test_socket_reponse_ok
    get '/socket'
    assert_equal 503, last_response.status
    # TODO how to check websocket
  end
end
