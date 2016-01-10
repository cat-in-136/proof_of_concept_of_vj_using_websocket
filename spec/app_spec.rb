require_relative 'app_spec.rb'

describe "/" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "response OK" do
    get '/'
    expect(last_response.ok?).to eq(true)
  end
end

describe "/controller" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "response OK" do
    get '/controller'
    expect(last_response.ok?).to eq(true)
  end
end

describe "/socket" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "response NG" do
    get '/socket'
    expect(last_response.status).to eq(503)
    # TODO how to check websocket
  end
end

describe "/controller_socket" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "response NG" do
    get '/controller_socket'
    expect(last_response.status).to eq(503)
    # TODO how to check websocket
  end
end
